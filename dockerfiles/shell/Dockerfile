FROM cgr.dev/chainguard/wolfi-base

RUN \
    apk add --no-cache \
    bash \
    curl \
    rsync \
    git \
    openssl \
    ca-certificates \
    openssh-client && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*


COPY bashrc /root/.bashrc
CMD ["/bin/bash"]