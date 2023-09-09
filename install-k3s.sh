#!/bin/bash

set -euo pipefail

K3S_VERSION=${K3S_VERSION:v1.26.8}

tempdir=$(mktemp -d -p /tmp)

curl -sSfL -o "${tempdir}/k3s" "https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}%2Bk3s1/k3s"

chmod +x ./k3s

mv k3s /usr/local/bin/k3s

cat >/etc/systemd/system/k3s.service <<'EOF'
[Unit]
Description=Kubernetes Cluster with k3s
After=syslog.target network.target
ConditionFileIsExecutable=/usr/local/bin/k3s

[Service]
Type=notify
EnvironmentFile=-/etc/default/k3s.env

ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s $K3S_MODE $K3S_ARGS
KillMode=process
Delegate=yes
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s


[Install]
WantedBy=multi-user.target
EOF

case ${K3S_MODE:-server} in
bootstrap)
  cat >/etc/default/k3s.env <<'EOF'
K3S_MODE="server"
K3S_TOKEN=MODIFY_K3S_TOKEN
K3S_NODE_NAME=MODIFY_K3S_NODE_NAME
K3S_CLUSTER_INIT=true
K3S_KUBECONFIG_MODE=644

K3S_CLUSTER_ARGS="--node-ip $K3S_INTERNAL_IP --disable servicelb --disable traefik --tls-san MODIFY_K3S_CLUSTER_DOMAIN"
K3S_KUBEAPISERVER_ARGS="--kube-apiserver-arg default-not-ready-toleration-seconds=30 --kube-apiserver-arg default-unreachable-toleration-seconds=30"
K3S_KUBECTRL_ARGS="--kube-controller-arg node-monitor-period=20s --kube-controller-arg node-monitor-grace-period=20s"
K3S_KUBELET_ARGS="--kubelet-arg node-status-update-frequency=5s"
K3S_EXTRAS_ARGS="--node-label role=controlplane --node-taint role=controlplane:NoSchedule"

K3S_ARGS="$K3S_CLUSTER_ARGS $K3S_KUBEAPISERVER_ARGS $K3S_KUBECTRL_ARGS $K3S_KUBELET_ARGS $K3S_EXTRAS_ARGS"
EOF
  ;;
server)
  cat >/etc/default/k3s.env <<'EOF'
K3S_MODE="server"
K3S_URL=MODIFY_K3S_CLUSTER_URL
K3S_TOKEN=MODIFY_K3S_TOKEN
K3S_NODE_NAME=MODIFY_K3S_NODE_NAME
K3S_KUBECONFIG_MODE=644

K3S_CLUSTER_ARGS="--node-ip $K3S_INTERNAL_IP --disable servicelb --disable traefik"
K3S_KUBEAPISERVER_ARGS="--kube-apiserver-arg default-not-ready-toleration-seconds=30 --kube-apiserver-arg default-unreachable-toleration-seconds=30"
K3S_KUBECTRL_ARGS="--kube-controller-arg node-monitor-period=20s --kube-controller-arg node-monitor-grace-period=20s"
K3S_KUBELET_ARGS="--kubelet-arg node-status-update-frequency=5s"

K3S_EXTRAS_ARGS="--node-label role=controlplane --node-taint role=controlplane:NoSchedule"

K3S_ARGS="$K3S_CLUSTER_ARGS $K3S_KUBEAPISERVER_ARGS $K3S_KUBECTRL_ARGS $K3S_KUBELET_ARGS $K3S_EXTRAS_ARGS"
EOF
  ;;
agent)
  cat >/etc/default/k3s.env <<'EOF'
K3S_MODE="agent"
K3S_URL=MODIFY_K3S_CLUSTER_URL
K3S_TOKEN=MODIFY_K3S_TOKEN
K3S_NODE_NAME=MODIFY_K3S_NODE_NAME

K3S_KUBELET_ARGS="--kubelet-arg node-status-update-frequency=5s"

K3S_EXTRAS_ARGS="--node-label role=agent"
# K3S_EXTRAS_ARGS="--node-label role=agent --node-taint purpose=proxy:NoSchedule"

K3S_ARGS="$K3S_CLUSTER_ARGS $K3S_KUBELET_ARGS $K3S_EXTRAS_ARGS"
EOF
  ;;
esac
