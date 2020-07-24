FROM alpine

RUN apk update && apk add --no-cache strongswan

COPY isrgrootx1.pem.txt /isrgrootx1.pem.txt
COPY letsencryptauthorityx3.pem.txt /letsencryptauthorityx3.pem.txt
COPY x-charon-cmd.sh /usr/local/bin/x-charon-cmd

ENTRYPOINT ["/usr/local/bin/x-charon-cmd"]