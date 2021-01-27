FROM debian:bullseye-slim

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -y && \
    apt install -y -f --no-install-recommends \
        file \
        shellcheck \
        git \
        make && \
    rm -Rf /tmp/* /var/tmp/* /var/lib/apt/lists/* /usr/share/doc /usr/share/man

CMD ["shellcheck"]