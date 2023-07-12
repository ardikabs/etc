#!/bin/bash

wget -q "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -O - | tar -xz --strip-component=1 --directory=/usr/local/bin linux-amd64/helm
wget -q "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -O /usr/local/bin/kubectl
wget -q "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz" -O - | tar -xz --directory=/usr/local/bin helmfile
wget -q "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" -O - | tar -xz --directory=/usr/local/bin kustomize
wget -q "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux" -O /usr/local/bin/sops

chmod +x /usr/local/bin/{kubectl,helm,helmfile,kustomize,sops}

helm plugin install https://github.com/databus23/helm-diff --version "${HELM_PLUGIN_DIFF_VERSION}" >/dev/null 2>&1
helm plugin install https://github.com/chartmuseum/helm-push --version "${HELM_PLUGIN_PUSH_VERSION}" >/dev/null 2>&1
helm plugin install https://github.com/quintush/helm-unittest --version=${HELM_PLUGIN_UNITTEST_VERSION} >/dev/null 2>&1

exec "$@"
