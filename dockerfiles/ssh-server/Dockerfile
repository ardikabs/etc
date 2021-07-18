FROM ubuntu:latest

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"

ENV TERM xterm

USER root

COPY entrypoint.sh /docker-entrypoint.sh

RUN apt update -y && \
    apt install -y -f --no-install-recommends \
        bash \
        openssh-server \
        sudo \
        curl \
        git \
        ca-certificates \
        vim \
        openssh-sftp-server && \
    apt autoremove && \
    apt clean && \
    rm -Rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc /usr/share/man

RUN mkdir -p /var/run/sshd && \
    mkdir /root/.ssh && \
    chmod 700 /root/.ssh && \
    touch /root/.ssh/authorized_keys && \
    chmod 777 /docker-entrypoint.sh

EXPOSE 22
COPY sshd_config /etc/ssh/sshd_config

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["ssh-server"]