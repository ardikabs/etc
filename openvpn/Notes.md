# Installment
```bash
$ bash <(curl -sSf https://git.io/vpn)
```

# Cheatsheet
```bash
# Get delfie-hielman key with openssl
$ openssl dhparam -out dh.pem 2048

# Get tls-auth/tls-crypt key with openvpn
$ openvpn --genkey --secret secret.key

# Generate self-signed certificate for openvpn
$ openssl req -x509 \
    -newkey rsa:2048 \
    -days 3600 \
    -nodes \
    -keyout cert.key \
    -out cert.pem
```

# Configuration
## Server
```bash
# server.ovpn
port 1194
proto udp
dev tun
topology subnet
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
user nobody
group nogroup
persist-key
persist-tun

tls-server
auth SHA512
cipher CAMELLIA-128-OFB
dh dh.pem
key-direction 0
<tls-auth>
REDUCTED
</tls-auth>

<ca>
REDUCTED
</ca>

<cert>
REDUCTED
</cert>

<key>
REDUCTED
</key>

verb 3

```
## Client
```bash
# client.ovpn
client
dev tun
proto udp
remote 10.0.42.195 1194
resolv-retry infinite
nobind

persist-key
persist-tun

tls-client
auth SHA512
cipher CAMELLIA-128-OFB
remote-cert-tls server
key-direction 1
<tls-auth>
REDUCTED
</tls-auth>

<ca>
REDUCTED
</ca>

<cert>
REDUCTED
</cert>

<key>
REDUCTED
</key>
verb 3
```
