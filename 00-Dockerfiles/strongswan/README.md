# Strongswan IPSec Client
By default, it uses charon-cmd command to establish connection to IPSec server. It also includes Let's Encrypt public certificates by default (downloaded at the runtime) for easier use with IPSec servers using Let's Encrypt certificates.

Refer to this URL to retrieve the root and intermedita certificates from Let's Encrypt:
```
https://letsencrypt.org/certificates/
https://letsencrypt.org/certs/isrgrootx1.pem.txt
https://letsencrypt.org/certs/letsencryptauthorityx3.pem.txt
```
> 👀: Requires running Docker command with `--net=host --cap-add=NET_ADMIN` options so that the container can modify host network settings.

Example usage (replace `VPN_USER` and `VPN_HOST` accordingly):

```bash
$ docker run --rm -it --net host --cap-add=NET_ADMIN \
    -e VPN_USER=<username> \
    -e VPN_HOST=<vpn_host> \
    ardikabs/strongswan \
    --ike-proposal aes256-sha1-modp1024
```