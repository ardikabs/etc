FROM dtzar/helm-kubectl:3.1.1

ENV PATH="/usr/local/bin:${PATH}"
ARG HELMFILE_VERSION=v0.130.0
ARG KUSTOMIZE_VERSION=v3.8.4

RUN wget -O helmfile https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64 && \
    wget -O kustomize.tar.gz "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" && \
    tar -xvzf kustomize.tar.gz; rm -rf kustomize.tar.gz && \
    chmod +x helmfile; mv helmfile /usr/local/bin/ && \
    chmod +x kustomize; mv kustomize /usr/local/bin/