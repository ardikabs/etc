#!/bin/bash

wget -q "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm
wget -q "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -O /usr/local/bin/kubectl
wget -q "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64" -O /usr/local/bin/helmfile
wget -q "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" -O - | tar -xzO kustomize > /usr/local/bin/kustomize
wget -q "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux" -O /usr/local/bin/sops

chmod +x /usr/local/bin/{kubectl,helm,helmfile,kustomize,sops}
helm plugin install https://github.com/databus23/helm-diff --version "${HELM_DIFF_VERSION}" >/dev/null 2>&1

exec "$@"