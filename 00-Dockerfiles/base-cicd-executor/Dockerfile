FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive

ADD entrypoint.sh /usr/local/bin/entrypoint.base

RUN apt update -y && \
    apt install -y -f --no-install-recommends \
        git \
        wget \
        curl \
        openssh-client \
        gawk \
        unzip \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man && \
    apt-get clean

ENTRYPOINT ["/usr/local/bin/entrypoint.base"]