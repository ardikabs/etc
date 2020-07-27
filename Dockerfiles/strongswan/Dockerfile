FROM alpine

RUN apk update && apk add --no-cache strongswan

COPY isrgrootx1.pem.txt /isrgrootx1.pem.txt
COPY letsencryptauthorityx3.pem.txt /letsencryptauthorityx3.pem.txt
COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]