#!/bin/bash

TENANT_ID=$1
VCLUSTER_VERSION=0.25.1

helm upgrade --install "${TENANT_ID}" vcluster \
  --values vcluster.yaml \
  --repo https://charts.loft.sh \
  --namespace "${TENANT_ID}" \
  --version "${VCLUSTER_VERSION}" \
  --create-namespace