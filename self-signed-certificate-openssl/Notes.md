# How To
```bash
# Generate Certificate Authority

openssl req \
    -x509 \
    -nodes \
    -days 1825 \
    -newkey rsa:2048 \
    -sub "/C=ID/ST=East Java/L=Gresik/O=Cloud Infrastructure/OU=Certificate Authority" \
    -keyout ca.key \
    -out ca.pem

# ----------------
# Client
# ----------------

# Generate client private key
openssl genrsa 2048 -out client.key

# Generate Certificate Request
openssl req \
    -new \
    -days 360 \
    -key client.key \
    -out client.csr

# ----------------
# Signed certificate by CA
# ----------------

cat > openssl.cnf <<EOF
[req]
default_bits = 2048
encrypt_key  = no # Change to encrypt the private key using des3 or similar
default_md   = sha256
prompt       = no
utf8         = yes

# Specify the DN here so we aren't prompted (along with prompt = no above).
distinguished_name = req_distinguished_name
# Extensions for SAN IP and SAN DNS
req_extensions = v3_req

# Be sure to update the subject to match your organization.
[req_distinguished_name]
C  = ID
ST = East Java
L  = Gresik
O  = Side Project
OU = Certificate Demo
CN = demo.project.ardikabs.com

# Allow client and server auth. You may want to only allow server auth.
# Link to SAN names.
[v3_req]
basicConstraints     = CA:FALSE
subjectKeyIdentifier = hash
keyUsage             = digitalSignature, keyEncipherment
extendedKeyUsage     = clientAuth, serverAuth
subjectAltName       = @alt_names

# Alternative names are specified as IP.# and DNS.# for IP addresses and
# DNS accordingly.
[alt_names]
IP.1  = 127.0.0.1
DNS.1 = openssl.demo.project.ardikabs.com
DNS.2 = openssl.demo.dev
EOF

openssl x509
    -req \
    -in client.csr \
    -sha256 \
    -days 360 \
    -CA ca.pem \
    -CAkey ca.key \
    -CAcreateserial \
    -out client.pem \
    -extfile openssl.cnf
```
# References
[SSL CA for local https development](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/)