#!/bin/sh
curl -sSfL https://letsencrypt.org/certs/isrgrootx1.pem.txt -o /tmp/isrgrootx1.pem.txt
curl -sSfL https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt -o /tmp/letsencryptauthorityx3.pem.txt

if [ -n "${VPN_PASSWORD:-}" ]; then
    expect -c "
    eval spawn /usr/sbin/charon-cmd --identity $VPN_USER --host $VPN_HOST --cert /tmp/isrgrootx1.pem.txt --cert /tmp/letsencryptauthorityx3.pem.txt $*
    sleep 1
    expect {
        \"EAP password: \" { send $VPN_PASSWORD\r }
    }
    interact
    "
else
    /usr/sbin/charon-cmd \
        --identity "$VPN_USER" \
        --host "$VPN_HOST" \
        --cert /tmp/isrgrootx1.pem.txt \
        --cert /tmp/letsencryptauthorityx3.pem.txt \
        "$@"
fi

tail -f /dev/null