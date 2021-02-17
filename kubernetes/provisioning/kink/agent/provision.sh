#!/usr/bin/env bash

# Update apt packages
set -ex
sudo yum install -y curl

echo -e "\nRunning scripts as '$(whoami)'\n\n"

cat > ~/cleanup-kink-agent.sh << 'EOF'
#!/bin/bash

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

echo "$(timestamp) [INFO] Stopping kink-agent"
docker rm -f kink-agent >/dev/null 2>&1 || true
EOF

cat > ~/start-kink-agent.sh << 'EOF'
#!/bin/bash

KINK_APISERVER="kink.k8s.ardikabs.com"
run=0

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

run_docker() {
  echo "$(timestamp) [INFO] Running kink-agent"
  docker run --name kink-agent -e "KINK_APISERVER=${KINK_APISERVER}" --privileged ardikabs/kink:v1.16.15 agent &

  if [ $? -ne 0 ]; then
    echo "$(timestamp) [ERROR] Got error from internal docker, exiting." >&2
    exit 1
  fi
}

run_agent() {
  if [[ "${run}" -eq 1 ]]; then
    echo "$(timestamp)] [INFO] Stopping kink-agent"
    docker rm -f kink-agent >/dev/null 2>&1 || true

    run_docker
  elif [[ -z "$(docker ps -q --filter name=kink-agent)" ]]; then
    run_docker
  fi
  run=0
}

while true; do
  if [ "$(curl -sfL -w '%{http_code}' -o /dev/null http://${KINK_APISERVER}:10251/healthz)" -ne 200 ]; then
    echo "$(timestamp) [WARNING] KINK API Server (${KINK_APISERVER}) is not ready!"
    until [ $(curl -sfL -w '%{http_code}' -o /dev/null http://${KINK_APISERVER}:10251/healthz) -eq 200 ]; do
      echo "$(timestamp) [INFO] Waiting KINK API Server (${KINK_APISERVER}) to be ready ..."
      sleep 1
    done
    run=1
  fi
  run_agent
  sleep 1
done
EOF

echo -e "\nMaking scripts executable"
chmod +x ~/{start,cleanup}-kink-agent.sh
sudo mv ~/{start,cleanup}-kink-agent.sh /usr/bin/

echo -e "\nConfigure KINK Agent Service Unit File"
cat > ~/kink-agent.service << EOF
[Unit]
Description=Kubernetes in Kubernetes Agent
After=syslog.target network.target
ConditionFileIsExecutable=/bin/docker

[Service]
StartLimitInterval=5
StartLimitBurst=10
ExecPreStart=/bin/bash /usr/bin/cleanup-kink-agent.sh
ExecStart=/bin/bash /usr/bin/start-kink-agent.sh
ExecStop=/bin/bash /usr/bin/cleanup-kink-agent.sh
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target
EOF

# Move SystemD service unit file to /etc/systemd/system
sudo mv ~/kink-agent.service /etc/systemd/system/
sudo systemctl daemon-reload

sudo systemctl enable docker
sudo systemctl enable kink-agent