#!/usr/bin/env bash

# Update apt packages
set -ex
sudo yum install -y curl

echo -e "\nRunning scripts as '$(whoami)'\n\n"

echo -e "Configure default kink-agent environment"
# Refer to this documentation for the available arguments on kink-agent
# node-metadata-related: https://rancher.com/docs/k3s/latest/en/installation/install-options/agent-config/#node
# networking-related: https://rancher.com/docs/k3s/latest/en/installation/install-options/agent-config/#networking
# component-related: https://rancher.com/docs/k3s/latest/en/installation/install-options/agent-config/#customized-flags
cat > ~/kink-agent.env << EOF
KINK_APISERVER=${KINK_APISERVER:-}
INSTALL_KINK_AGENT_ARGS="${INSTALL_KINK_AGENT_ARGS:-}"
EOF
sudo mv ~/kink-agent.env /etc/default/kink-agent

echo -e "Configure kink-agent cleanup script"
cat > ~/cleanup-kink-agent.sh << 'EOF'
#!/bin/bash

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

echo "$(timestamp) [INFO] Stopping kink-agent"
docker rm -f kink-agent >/dev/null 2>&1 || true
EOF

echo -e "Configure kink-agent startup script"
cat > ~/start-kink-agent.sh << 'EOF'
#!/bin/bash

KINK_AGENT_ARGS="$*"
KINK_APISERVER="${KINK_APISERVER:-kink.k8s.ardikabs.com}"
run=0

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

run_docker() {
  echo "$(timestamp) [INFO] Running kink-agent"
  docker rm -f kink-agent >/dev/null 2>&1 || true
  docker run --net=host --privileged \
    --name kink-agent \
    -e "KINK_APISERVER=${KINK_APISERVER}" \
    ardikabs/kink:v1.16.15 agent "${KINK_AGENT_ARGS}" &

  if [ $? -ne 0 ]; then
    echo "$(timestamp) [ERROR] Got error from internal docker, exiting." >&2
    exit 1
  fi
}

run_agent() {
  if [[ "${run}" -eq 1 ]]; then
    echo "$(timestamp)] [INFO] Stopping kink-agent"
    run_docker
  elif [[ -z "$(docker ps -q --filter name=kink-agent)" ]]; then
    echo "$(timestamp)] [WARNING] kink-agent instance not found, restarting ..."
    run_docker
  elif docker logs kink-agent --tail=5 2>&1 | grep -Eq "(error getting node|failed to get node)"; then
    echo "$(timestamp)] [WARNING] kink-agent node not found, restarting ..."
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
cat > ~/kink-agent.service << 'EOF'
[Unit]
Description=Kubernetes in Kubernetes Agent
After=syslog.target network.target
ConditionFileIsExecutable=/bin/docker

[Service]
StartLimitInterval=5
StartLimitBurst=10
EnvironmentFile=-/etc/default/kink-agent
ExecPreStart=/bin/bash /usr/bin/cleanup-kink-agent.sh
ExecStart=/bin/bash /usr/bin/start-kink-agent.sh ${INSTALL_KINK_AGENT_ARGS}
ExecStop=/bin/bash /usr/bin/cleanup-kink-agent.sh
Restart=always
RestartSec=120

[Install]
WantedBy=multi-user.target
EOF

echo -e "\nConfigure Docker cleanup service unit file"
cat > ~/docker-cleanup.service << 'EOF'
[Unit]
Description=Docker clean up
Wants=docker-cleanup.timer

[Service]
ExecStartPre=/bin/docker system prune -f
ExecStart=/bin/docker volume prune -f

[Install]
WantedBy=multi-user.target
EOF

# Setup docker cleanup timer which run in the middle of night everyday
echo -e "\nConfigure Docker cleanup timer unit file"
cat > ~/docker-cleanup.timer << EOF
[Unit]
Description=Docker clean up job
Requires=docker-cleanup.service

[Timer]
Unit=docker-cleanup.service
OnCalendar=*-*-* 00:00:00
AccuracySec=1s

[Install]
WantedBy=multi-user.target
EOF


# Move SystemD service unit file to /etc/systemd/system
sudo mv ~/kink-agent.service /etc/systemd/system/
sudo mv ~/docker-cleanup.service /etc/systemd/system/
sudo mv ~/docker-cleanup.timer /etc/systemd/system/
sudo systemctl daemon-reload

sudo systemctl enable docker
sudo systemctl enable kink-agent
sudo systemctl enable docker-cleanup.timer