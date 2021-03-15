# certbot usage

# Plugins
```bash
$ certbot --help plugins
```

## DNS01 Challenge with Cloudflare
```bash
$ sudo apt install python3-certbot-dns-cloudflare
$ certbot plugins
* dns-cloudflare
Description: Obtain certificates using a DNS TXT record (if you are using
Cloudflare for DNS).
Interfaces: IAuthenticator, IPlugin
Entry point: dns-cloudflare =
certbot_dns_cloudflare.dns_cloudflare:Authenticator
...

$ certbot --help dns-cloudflare
```

## Request DNS01 Challenge with Cloudflare
```bash
DOMAIN=super.ardikabs.com
EMAIL=me@ardikabs.com

/usr/bin/certbot -n certonly \
  --agree-tos \
  --email $EMAIL \
  -d $DOMAIN \
  --dns-cloudflare
```