#!/bin/bash
set -o nounset
set -o pipefail

KUBELET_RESTART=/tmp/kubelet-restart-count
DOCKER_RESTART=/tmp/docker-restart-count

[[ ! -e ${KUBELET_RESTART} ]] && echo "0" > ${KUBELET_RESTART}
[[ ! -e ${DOCKER_RESTART} ]] && echo "0" > ${DOCKER_RESTART}

function kubelet_restart(){
  echo -e "Reason: $1"
  echo "Kubelet is unhealthy!"
  echo "Killing kubelet..."
  pkill --signal 9 kubelet
  sleep 5
  echo "Re-starting kubelet.."
  systemctl start kubelet
  echo "$(($(cat ${KUBELET_RESTART}) + 1))" > ${KUBELET_RESTART}
  echo -e "Kubelet restart count: $(cat ${KUBELET_RESTART})"

  sleep 120
}

function docker_monitoring {
  while true; do
    if ! timeout 60 docker ps > /dev/null; then
      echo "Docker daemon failed!"
      pkill --signal 9 docker
      # Wait for a while, as we don't want to kill it again before it is really up.
      sleep 120
      systemctl start docker
      echo "$(($(cat ${DOCKER_RESTART}) + 1))" > ${DOCKER_RESTART}
      echo -e "Docker restart count: $(cat ${DOCKER_RESTART})"

    else
      sleep "${SLEEP_SECONDS}"
    fi
  done
}

# shellcheck disable=SC2086
function kubelet_monitoring {
  echo "Wait for 2 minutes for kubelet to be functional"
  sleep 120

  local -r max_seconds
  local output

  max_seconds=20
  output=""

  while true; do
    if ! output=$(curl -m "${max_seconds}" -f -s -S http://127.0.0.1:10248/healthz 2>&1); then
      kubelet_restart ${output}

    elif output=$(journalctl -u kubelet -n50 | grep -m1 -o "use of closed network connection" 2>&1); then
      kubelet_restart "Kubelet has caught '${output}'"

    else
      sleep "${SLEEP_SECONDS}"
    fi
  done
}

############## Main Function ################
if [[ "$#" -ne 1 ]]; then
  echo "Usage: health-monitor.sh <docker/kubelet>"
  exit 1
fi

SLEEP_SECONDS=30
case $1 in
    docker)
    docker_monitoring
    ;;
    kubelet)
    kubelet_monitoring
    ;;
    *)
    echo -e "Health monitoring for $1 is not yet supported"
    ;;
esac

