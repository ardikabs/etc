#!/bin/sh

curl -sSfL https://letsencrypt.org/certs/isrgrootx1.pem.txt -o /tmp/isrgrootx1.pem.txt
curl -sSfL https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt -o /tmp/letsencryptauthorityx3.pem.txt

/usr/sbin/charon-cmd \
    --identity $VPN_USER \
    --host $VPN_HOST \
    --cert /tmp/isrgrootx1.pem.txt \
    --cert /tmp/letsencryptauthorityx3.pem.txt \
    "$@"