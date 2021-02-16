#!/bin/sh

set -o errexit
set -o nounset

if [ "${KINK_API_SERVER:-"x"}" = x ]; then
  K3S_ARGS=""

  if [ -n "${KINK_MASTER_SAN:-}" ]; then
    KINK_MASTER_SAN=$(echo "${KINK_MASTER_SAN}" | tr "," " ")
    for san in ${KINK_MASTER_SAN}; do
      K3S_ARGS="${K3S_ARGS} --tls-san ${san}"
    done
  fi

  set -- k3s server \
    --no-deploy=servicelb \
    --no-deploy=traefik \
    --https-listen-port=443 \
    --token="${KINK_TOKEN:-"kink-k3s"}" \
    --node-taint master=true:NoExecute \
    "${K3S_ARGS}"
else
  echo "wait for api server to up..."
  until wget -q --spider http://"${KINK_API_SERVER}":10251/healthz 2>/dev/null; do
    echo "."
    sleep 1
  done
  echo "done"

  set -- k3s agent --server=https://"${KINK_API_SERVER}" --token="${KINK_TOKEN:-"kink-k3s"}"
fi

exec "$@"