FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive

ENV PATH="$PATH:/usr/local/bin:/opt/shared"
ADD entrypoint.sh /bin/entrypoint.sh

RUN apt update -y && \
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
    apt-get clean

ENTRYPOINT ["/bin/entrypoint.sh"]