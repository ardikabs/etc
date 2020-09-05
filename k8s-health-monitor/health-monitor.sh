#!/bin/bash
set -o nounset
set -o pipefail

function docker_monitoring {
  while [ 1 ]; do
    if ! timeout 60 docker ps > /dev/null; then
      echo "Docker daemon failed!"
      pkill --signal 9 docker
      # Wait for a while, as we don't want to kill it again before it is really up.
      sleep 120
      systemctl start docker
    else
      sleep "${SLEEP_SECONDS}"
    fi
  done
}

function kubelet_monitoring {
  echo "Wait for 2 minutes for kubelet to be functional"
  sleep 120
  local -r max_seconds=20
  local output=""
  while [ 1 ]; do
    if ! output=$(curl -m "${max_seconds}" -f -s -S http://127.0.0.1:10255/healthz 2>&1); then
      # Print the response and/or errors.
      echo $output
      echo "Kubelet is unhealthy!"
      echo "Killing kubelet..."
      pkill --signal 9 kubelet
      sleep 5
      echo "Re-starting kubelet.."
      systemctl start kubelet
      sleep 120
    elif ! output=$(journalctl -u kubelet -n50 | grep -m1 -o "use of closed network connection" 2>&1); then
      echo "Kubelet caught error for 'use of closed network connection'"
      echo "Killing kubelet ..."
      pkill --signal 9 kubelet
      sleep 5
      echo "Re-starting kubelet.."
      systemctl start kubelet
      sleep 120
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

