FROM debian:stretch-slim

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"

ENV DEBIAN_FRONTEND noninteractive

ENV PATH="$PATH:/usr/local/bin:/opt/shared"

COPY entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh && \
    apt update -y && \
    apt install -y -f --no-install-recommends \
        sudo \
        bash \
        git \
        wget \
        curl \
        openssh-client \
        gawk \
        unzip \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man && \
    ln -s /bin/entrypoint.sh /usr/local/bin/bash && \
    apt-get clean

ENTRYPOINT ["/bin/entrypoint.sh"]