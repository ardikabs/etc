FROM alpine:3.11

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"
LABEL org.label-schema.name="k8s-deployer" \
      org.label-schema.url="https://hub.docker.com/r/ardikabs/k8s-deployer/" \
      org.label-schema.vcs-url="https://github.com/ardikabs/etc"

ENV PATH="/usr/local/bin:${PATH}"
ENV HELM_VERSION=v3.3.0
ENV KUBECTL_VERSION=v1.18.20
ENV HELMFILE_VERSION=v0.140.0
ENV KUSTOMIZE_VERSION=v3.8.4
ENV SOPS_VERSION=v3.6.1
ENV HELM_DIFF_VERSION=v3.1.3

COPY install.sh /install.sh

RUN chmod +x /install.sh && \
    apk add --no-cache \
        gettext \
        make \
        openssh-client \
        curl \
        git \
        ca-certificates \
        gnupg \
        bash && \
    bash /install.sh && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

CMD [ "/usr/local/bin/kubectl" ]