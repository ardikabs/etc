FROM jnorwood/helm-docs:v1.11.0 as helm-docs

###

FROM alpine:3.11

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"
LABEL org.label-schema.name="kubeexec" \
    org.label-schema.url="https://ghcr.io/ardikabs/etc/kubeexec" \
    org.label-schema.vcs-url="https://github.com/ardikabs/etc"

ENV PATH="/usr/local/bin:${PATH}"

ENV KUBECTL_VERSION=1.27.1
ENV KUSTOMIZE_VERSION=5.0.1
ENV SOPS_VERSION=3.7.3
ENV ARGOCD_VERSION=2.8.0

ENV HELM_VERSION=3.12.0
ENV HELMFILE_VERSION=0.156.0
ENV HELM_PLUGIN_DIFF_VERSION=3.8.1
ENV HELM_PLUGIN_PUSH_VERSION=0.10.4
ENV HELM_PLUGIN_UNITTEST_VERSION=0.3.4

ENV HELM_CHART_RELEASER_VERSION=1.6.0
ENV HELM_CHART_TESTING_VERSION=3.9.0

COPY entrypoint.sh /docker-entrypoint.sh
COPY --from=helm-docs /usr/bin/helm-docs /usr/local/bin/

RUN chmod +x /docker-entrypoint.sh && \
    apk add --no-cache \
    gettext \
    make \
    openssh-client \
    curl \
    git \
    ca-certificates \
    gnupg \
    jq \
    bash && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

RUN bash /docker-entrypoint.sh

CMD [ "/docker-entrypoint.sh" ]
