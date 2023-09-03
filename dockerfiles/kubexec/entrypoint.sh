#!/bin/bash

arch=amd64
case $(uname -m) in
aarch64) arch=arm64 ;;
x86_64) arch=amd64 ;;
esac

install() {
  local name
  name=$1
  version="${!name}"

  if grep "$name ${!name}" /usr/share/.installed-version >/dev/null 2>&1; then
    echo >&2 "$name: the tool already exists, skipping..."
    return
  fi

  echo >&2 "$name: installing"
  case $name in
  KUBECTL_VERSION) wget -q "https://storage.googleapis.com/kubernetes-release/release/v${version}/bin/linux/${arch}/kubectl" -O /usr/local/bin/kubectl ;;
  ARGOCD_VERSION) wget -q "https://github.com/argoproj/argo-cd/releases/download/v${version}/argocd-linux-${arch}" -O /usr/local/bin/argocd ;;
  KUSTOMIZE_VERSION) wget -q "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${version}/kustomize_v${version}_linux_${arch}.tar.gz" -O - | tar -xz --directory=/usr/local/bin kustomize ;;
  SOPS_VERSION) wget -q "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.${arch}" -O /usr/local/bin/sops ;;
  HELM_VERSION) wget -q "https://get.helm.sh/helm-v${version}-linux-${arch}.tar.gz" -O - | tar -xz --strip-component=1 --directory=/usr/local/bin "linux-${arch}/helm" ;;
  HELMFILE_VERSION) wget -q "https://github.com/helmfile/helmfile/releases/download/v${version}/helmfile_${version}_linux_${arch}.tar.gz" -O - | tar -xz --directory=/usr/local/bin helmfile ;;
  HELM_CHART_RELEASER_VERSION) wget -q "https://github.com/helm/chart-releaser/releases/download/v${version}/chart-releaser_${version}_linux_${arch}.tar.gz" -O - | tar -xz --directory=/usr/local/bin cr ;;
  HELM_CHART_TESTING_VERSION) wget -q "https://github.com/helm/chart-testing/releases/download/v${version}/chart-testing_${version}_linux_${arch}.tar.gz" -O - | tar -xz --directory=/usr/local/bin ct ;;
  HELM_PLUGIN_DIFF_VERSION) helm plugin install https://github.com/databus23/helm-diff --version "${version}" >/dev/null 2>&1 ;;
  HELM_PLUGIN_PUSH_VERSION) helm plugin install https://github.com/chartmuseum/helm-push --version "${version}" >/dev/null 2>&1 ;;
  HELM_PLUGIN_UNITTEST_VERSION) helm plugin install https://github.com/quintush/helm-unittest --version "${version}" >/dev/null 2>&1 ;;
  esac

  echo "$name" "${!name}" >>/usr/share/.installed-version
}

for var in $(env | cut -d '=' -f 1); do
  # Check if the variable ends with _VERSION
  if [[ $var == *_VERSION ]]; then
    install $var
  fi
done

chmod +x /usr/local/bin/{kubectl,argocd,kustomize,sops,helm,helmfile,ct,cr} || true
exec "$@"
