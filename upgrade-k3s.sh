#!/bin/bash
set -euo pipefail

K3S_VERSION=${K3S_VERSION:v1.26.8}

tempdir=$(mktemp -d -p /tmp)

curl -sSfL -o "${tempdir}/k3s" "https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}%2Bk3s1/k3s"

chmod +x "${tempdir}/k3s"

mv "${tempdir}/k3s" /usr/local/bin/k3s

systemctl stop k3s

sleep 1

systemctl restart k3s
