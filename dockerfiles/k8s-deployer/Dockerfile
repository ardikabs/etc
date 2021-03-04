FROM alpine:3.11

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"
LABEL org.label-schema.name="k8s-deployer" \
      org.label-schema.url="https://hub.docker.com/r/ardikabs/k8s-deployer/" \
      org.label-schema.vcs-url="https://github.com/ardikabs/etc"

ENV PATH="/usr/local/bin:${PATH}"

ARG HELM_VERSION=v3.2.0
ARG KUBECTL_VERSION=v1.16.10
ARG HELMFILE_VERSION=v0.130.0
ARG KUSTOMIZE_VERSION=v3.8.4
ARG SOPS_VERSION=v3.6.1

RUN apk add --no-cache \
        make \
        openssh-client \
        curl \
        git \
        ca-certificates \
        gnupg \
        bash && \
    wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && \
    wget -q https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64 -O /usr/local/bin/helmfile && \
    wget -q https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz -O - | tar -xzO kustomize > /usr/local/bin/kustomize && \
    wget -q https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux -O /usr/local/bin/sops && \
    bash -c "chmod +x /usr/local/bin/{kubectl,helm,helmfile,kustomize,sops}" && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* && \
    helm plugin install https://github.com/databus23/helm-diff --version v3.1.3