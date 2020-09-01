FROM alpine

RUN apk update \
    && apk add --no-cache \
        curl \
        strongswan \
        ca-certificates

COPY entrypoint.sh /usr/local/bin/entrypoint

ENTRYPOINT ["/usr/local/bin/entrypoint"]