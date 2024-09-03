#!/bin/bash

set -euo pipefail

basedir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

setup_metallb() {
  local cluster_name
  cluster_name=$1

  cidr_block=$(docker network inspect "${cluster_name}" | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
  cidr_base_addr=${cidr_block%???}
  ingress_first_addr=$(echo "${cidr_base_addr}" | awk -F'.' '{print $1,$2,255,0}' OFS='.')
  ingress_last_addr=$(echo "${cidr_base_addr}" | awk -F'.' '{print $1,$2,255,255}' OFS='.')
  ingress_range=$ingress_first_addr-$ingress_last_addr

  sleep 1

  cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: primary-pool
  namespace: metallb-system
spec:
  addresses:
  - $ingress_range
EOF

  cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - primary-pool
EOF
}

main() {
  cluster_name=$1

  K3D_FIX_DNS=0 k3d cluster create "${cluster_name}" --config "${basedir}/config.yaml"

  sleep 2

  kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml --wait=true

  kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system

  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml --wait=true

  kubectl wait --for=condition=ready pod -l app=metallb -n metallb-system

  setup_metallb "k3d-${cluster_name}"
}

main "$@"
