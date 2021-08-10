FROM alpine

LABEL maintainer "Ardika Bagus <me@ardikabs.com>"

RUN apk update && \
    apk add --no-cache \
        expect \
        curl \
        strongswan \
        ca-certificates

COPY entrypoint.sh /usr/local/bin/entrypoint

ENTRYPOINT ["/usr/local/bin/entrypoint"]