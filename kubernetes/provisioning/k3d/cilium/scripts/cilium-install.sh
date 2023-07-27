#!/bin/bash

set -e

cat >/tmp/cilium-init.sh <<EOF
#!/bin/sh

set -xe
# needed for cilium
mount bpffs -t bpf /sys/fs/bpf
mount --make-shared /sys/fs/bpf

mkdir -p /run/cilium/cgroupv2
mount -t cgroup2 none /run/cilium/cgroupv2
mount --make-shared /run/cilium/cgroupv2/
EOF

machine_list=(
  k3d-sandbox-01-server-0
  k3d-sandbox-01-agent-0
  k3d-sandbox-01-serverlb
)

for host in "${machine_list[@]}"; do
  docker cp /tmp/cilium-init.sh $host:/tmp/cilium-init.sh
  docker exec $host sh /tmp/cilium-init.sh
done

cat >/tmp/values.yaml <<EOF
cluster:
  id: 0
  name: sandbox-01
encryption:
  nodeEncryption: false
externalIPs:
  enabled: true
ipam:
  mode: kubernetes
k8sServiceHost: sandbox-01.k8s.ardikabs.com
k8sServicePort: 16443
kubeProxyReplacement: strict
operator:
  replicas: 1
serviceAccounts:
  cilium:
    name: cilium
  operator:
    name: cilium-operator
hubble:
  enabled: true

  ui:
    enabled: true
  relay:
    enabled: true

clustermesh:
  useAPIServer: true

  config:
    enable: true
    domain: mesh.ardikabs.com

    clusters: []
    # # -- Name of the cluster
    # - name: cluster1
    # # -- Address of the cluster, use this if you created DNS records for
    # # the cluster Clustermesh API server.
    #   address: cluster1.mesh.cilium.io
    # # -- Port of the cluster Clustermesh API server.
    #   port: 2379
    # # -- IPs of the cluster Clustermesh API server, use multiple ones when
    # # you have multiple IPs to access the Clustermesh API server.
    #   ips:
    #   - 172.18.255.201
    # # -- base64 encoded PEM values for the cluster client certificate, private key and certificate authority.
    #   tls:
    #     cert: ""
    #     key: ""

  tls:
    auto:
      enabled: true
      method: helm

    server:
      extraDnsNames: []
      extraIpAddresses: []

  service:
    type: NodePort

externalWorkloads:
  enabled: true

tls:
  ca:
    cert: <reducted base64 encoded certificate authority>
    key: <reducted base64 encoded certificate key>

tunnel: vxlan
EOF

helm repo add cilium https://helm.cilium.io/
helm repo update

helm upgrade --install cilium cilium/cilium \
  --version 1.13.3 \
  -n kube-system \
  -f /tmp/values.yaml
