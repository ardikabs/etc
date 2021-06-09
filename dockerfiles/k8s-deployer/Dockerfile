FROM alpine:3.11

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"
LABEL org.label-schema.name="k8s-deployer" \
      org.label-schema.url="https://hub.docker.com/r/ardikabs/k8s-deployer/" \
      org.label-schema.vcs-url="https://github.com/ardikabs/etc"

ENV PATH="/usr/local/bin:${PATH}"
ENV HELM_VERSION=v3.2.0
ENV KUBECTL_VERSION=v1.16.10
ENV HELMFILE_VERSION=v0.130.0
ENV KUSTOMIZE_VERSION=v3.8.4
ENV SOPS_VERSION=v3.6.1
ENV HELM_DIFF_VERSION=v3.1.3

COPY entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh && \
    apk add --no-cache \
        make \
        openssh-client \
        curl \
        git \
        ca-certificates \
        gnupg \
        bash && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* && \
    ln -s /docker-entrypoint.sh /usr/local/bin/bash

ENTRYPOINT [ "/docker-entrypoint.sh" ]