#!/bin/sh

set -o errexit
set -o nounset

KINK_ARGS=""

parseArgs() {
  for san in $(echo "${KINK_APISERVER_SAN}" | tr ',' ' '); do
    KINK_ARGS="${KINK_ARGS} --tls-san ${san}"
  done

  for ip in $(echo "${KINK_EXTERNAL_IPS:-}" | tr ',' ' '); do
    KINK_ARGS="${KINK_ARGS} --node-external-ip ${ip}"
  done

  if [ -n "${KINK_EXTERNAL_IP:-}" ]; then KINK_ARGS="${KINK_ARGS} --node-external-ip ${KINK_EXTERNAL_IP}"; fi

  if [ -n "${KINK_APISERVER:-}" ]; then KINK_ARGS="${KINK_ARGS} --server https://${KINK_APISERVER}:${KINK_APISERVER_PORT:-443}"; fi

  KINK_ARGS="${KINK_ARGS} --token ${KINK_TOKEN:-"k3s-kink"}"
}

main() {
  opt=${1:-''}

  case $opt in
    server)
      shift 1
      parseArgs
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
      [ -n "${KINK_APISERVER:-}" ] || {
          echo "\$KINK_APISERVER required, exiting..." >&2
          exit 1
      }
      parseArgs
      KINK_ARGS="${KINK_ARGS} $*"
      shift $#

      echo "wait for api server to up..."
      until wget -q --spider http://"${KINK_APISERVER}":10251/healthz 2>/dev/null; do
        echo "."
        sleep 1
      done

      eval "set -- k3s agent ${KINK_ARGS}"
    ;;
  esac

  printf "Running the following command: \n %s \n\n" "$*"
  exec "$@"
}

main "$@"