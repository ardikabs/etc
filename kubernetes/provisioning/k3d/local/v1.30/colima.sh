#!/bin/bash

set -euo pipefail

colima_profile=$1
k3d_cluster_name=$2

colima_host_ip=$(ifconfig bridge100 | grep "inet " | cut -d' ' -f2)
colima_vm_ip=$(colima list | grep "${colima_profile:-"default"}" | grep docker | awk '{print $8}')
colima_vm_iface=$(colima ssh -- "ip" "-br" "addr" "show" "to" "$colima_vm_ip" | tr -s ' ' | awk '{print $1}')

k3d_net=$(docker network inspect "k3d-${k3d_cluster_name}" -f '{{.IPAM.Config}}' | cut -d'{' -f2)
k3d_cidr=$(echo "$k3d_net" | awk '{print $1}')   # 172.18.0.0/16
k3d_net_ip=$(echo "$k3d_net" | awk '{print $1}') # 172.18.0.1 -> gateway
k3d_iface=$(colima ssh -- "ip" "-br" "addr" "show" "to" "$k3d_net_ip" | tr -s ' ' | awk '{print $1}')

# executing to colima vm: 'sudo iptables -A FORWARD -s 192.168.106.1 -d 172.18.0.0/16 -i col0 -o br-1a2b3c4d5e6f -p tcp -j ACCEPT'
colima ssh -- "bash" \
  "-c" \
  "sudo iptables -A FORWARD -s $colima_host_ip -d $k3d_cidr -i $colima_vm_iface -o $k3d_iface -p tcp -j ACCEPT"

# add ip route table to colima host
ip ro add "$k3d_cidr" via "$colima_vm_ip"
