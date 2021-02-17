#!/bin/sh

set -o errexit
set -o nounset

KINK_ARGS=""

err() {
  echo "$*" >&2
  exit 1
}

resolve() {
  nslookup "$1" | awk '/^Address: / { print $2 }'
}

parse_env() {
  # Resolving external address to IPs
  # also add external address to API Server SAN
  if [ -n "${KINK_EXTERNAL_ADDRESS:-}" ]; then
    until [ -n "$(resolve "${KINK_EXTERNAL_ADDRESS}")" ]; do
      echo "waiting address ${KINK_EXTERNAL_ADDRESS} to resolve ..."
      sleep 1
    done

    result=$(resolve "${KINK_EXTERNAL_ADDRESS}" | tr '\n' ',')

    KINK_APISERVER_SAN="${KINK_APISERVER_SAN:-},${KINK_EXTERNAL_ADDRESS}"
    KINK_EXTERNAL_IPS="${KINK_EXTERNAL_IPS:-},${result}"
  fi

  # Parsing env for single value flag
  if [ -n "${KINK_APISERVER:-}" ]; then KINK_ARGS="${KINK_ARGS} --server https://${KINK_APISERVER}:${KINK_APISERVER_PORT:-443}"; fi
  if [ -n "${KINK_EXTERNAL_IP:-}" ]; then KINK_ARGS="${KINK_ARGS} --node-external-ip ${KINK_EXTERNAL_IP}"; fi

  # Parsing env for multiple values flag,
  # based on separated by comma values
  for san in $(echo "${KINK_APISERVER_SAN:-}" | tr ',' ' '); do KINK_ARGS="${KINK_ARGS} --tls-san ${san}"; done
  for ip in $(echo "${KINK_EXTERNAL_IPS:-}" | tr ',' ' '); do KINK_ARGS="${KINK_ARGS} --node-external-ip ${ip}"; done

  # Default k3s token
  KINK_ARGS="${KINK_ARGS} --token ${KINK_TOKEN:-"k3s-kink"}"
}

main() {
  opt=${1:-''}

  case $opt in
    server)
      shift 1
      parse_env
      KINK_ARGS="${KINK_ARGS} --no-deploy=servicelb"
      KINK_ARGS="${KINK_ARGS} --no-deploy=traefik"
      KINK_ARGS="${KINK_ARGS} --https-listen-port=443"
      KINK_ARGS="${KINK_ARGS} --node-taint master=true:NoExecute"
      KINK_ARGS="${KINK_ARGS} --token ${KINK_TOKEN:-"k3s-kink"}"
      KINK_ARGS="${KINK_ARGS} $*"
      shift $#

      eval "set -- k3s server ${KINK_ARGS}"
    ;;
    agent)
      shift 1
      [ -n "${KINK_APISERVER:-}" ] || err "\$KINK_APISERVER required for agent setup, exiting..."

      parse_env
      KINK_ARGS="${KINK_ARGS} $*"
      shift $#

      until wget -q --spider http://"${KINK_APISERVER}":10251/healthz 2>/dev/null; do
        echo "wait for api server to up..."
        sleep 1
      done

      eval "set -- k3s agent ${KINK_ARGS}"
    ;;
  esac

  printf "Running the following command: \n %s \n\n" "$*"
  exec "$@"
}

main "$@"