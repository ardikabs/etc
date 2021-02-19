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

parse_args() {
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

arg=${1:-}

# shellcheck disable=SC2086
case $arg in
  server)
    # Refer to this documentation for available arguments on server
    # doc: https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/

    shift 1
    parse_args

    set -- k3s server \
      --no-deploy=servicelb \
      --no-deploy=traefik \
      --https-listen-port=443 \
      --node-taint master=true:NoExecute \
      ${KINK_ARGS:+$KINK_ARGS $*}
  ;;
  agent)
    # Refer to this documentation for available arguments on agent
    # doc: https://rancher.com/docs/k3s/latest/en/installation/install-options/agent-config

    shift 1
    [ -n "${KINK_APISERVER:-}" ] || err "\$KINK_APISERVER required for agent setup, exiting..."
    parse_args

    until wget -q --spider http://"${KINK_APISERVER}":10251/healthz 2>/dev/null; do
      echo "wait for api server to up..."
      sleep 1
    done

    set -- k3s agent ${KINK_ARGS:+$KINK_ARGS $*}
  ;;
  *)
    echo "kink: expected first argument either 'server' or 'agent': got '${arg}'" >&2
    exit 1
  ;;
esac

printf "Running the following command: \n%b \n\n" "\033[1;33m$*\033[0m"
exec "$@"