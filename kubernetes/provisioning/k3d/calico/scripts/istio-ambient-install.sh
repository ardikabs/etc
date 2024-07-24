#!/bin/bash

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

istioctl install --set meshConfig.accessLogFile=/dev/stdout --set profile=ambient --skip-confirmation

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/experimental-install.yaml
