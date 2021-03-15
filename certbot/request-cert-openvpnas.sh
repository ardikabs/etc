#!/bin/bash

set -eu
DOMAIN=openvpn.mokapos.io

/usr/bin/certbot -n certonly \
  --agree-tos \
  --email <your-email> \
  -d $DOMAIN \
  --dns-cloudflare

# -------
# For openvpn access server
# -------
/usr/local/openvpn_as/scripts/confdba -mk cs.ca_bundle -v "$(cat /etc/letsencrypt/live/$DOMAIN/fullchain.pem)" >/dev/null
/usr/local/openvpn_as/scripts/confdba -mk cs.priv_key -v "$(cat /etc/letsencrypt/live/$DOMAIN/privkey.pem)" >/dev/null
/usr/local/openvpn_as/scripts/confdba -mk cs.cert -v "$(cat /etc/letsencrypt/live/$DOMAIN/cert.pem)" >/dev/null
