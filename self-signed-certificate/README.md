# Self Signed Certificate

## Pre-requisites
* Download [cfssl](https://pkg.cfssl.org/R1.2/cfssl_linux-amd64) and [cfssljson](https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64).

## Root Certificate Authority
1. Generate Certificate Authority with given [CSRJSON](ca/ca.csr.json)
2. Run below command
    ```bash
    $ cfssl gencert -initca ca/ca.csr.json | cfssljson -bare ca
    ```
3. Those command will produce 3 kind of files which:
    * ca.pem (Root Certificate Authority public key)<br>You can distribute this key to signing every TLS into server destination that signed by this CA
    * ca-key.pem (Root Certificate Authority private key)<br>You need to save it privately, we need this file for signing the other certificate.
    * ca.csr (Root Certificate Authority CSR)<br> You need to save it privately, we need this file for renew/resigning the certificate authority when expired.
4. In case Certificate Authority is expired, you need to prepare Root Certificate Authority Private Key (ca-key.pem) and then run below command
    ```bash
    $ cfssl gencert -initca \
        -ca-key=ca-key.pem \
        ca/ca.csr.json | cfssljson -bare ca
    ```

## Intermediate Certificate Authority (Optional)
1. Generate Intermediate CA with given [CSRJSON](ca/intermediate-ca.csr.json) and signed by Root CA
2. Run below command
    ```bash
    $ cfssl gencert -ca=ca.pem \
        -ca-key=ca-key.pem \
        -config=config.json \
        -profile=intermediate_ca \
        ca/intermediate-ca.csr.json | cfssljson -bare intermediate-ca
    ```
3. Those command will produce 3 kind of files which:
    * intermediate-ca.pem (Intermediate Certificate Authority public key)<br>You can distribute this key to signing every TLS into server destination that signed by this CA
    * intermediate-ca-key.pem (Intermediate Certificate Authority private key)<br>You need to save it privately, we need this file for signing the other certificate.
    * intermediate-ca.csr (Intermediate Certificate Authority CSR)<br> You need to save it privately, we need this file for renew/resigning the certificate authority when expired.
4. In case Intermediate Certificate Authority is expired, you need to prepare the Intermediate CA CSR and then run below command
    ```bash
    $ cfssl sign -ca=ca.pem \
        -ca-key=ca-key.pem \
        -config=config.json \
        -profile=intermediate_ca \
        -csr=intermediate-ca.csr | cfssljson -bare intermediate-ca
    ```

## Signing Client/Host Certificate
1. Generate Client/Host certificate with given [CSRJSON](hosts/consul.csr.json) and signed by Intermediate CA (if available) or Root CA
2. Run below command (using Intermediate CA)
    ```bash
    $ cfssl gencert -ca=intermediate-ca.pem \
        -ca-key=intermediate-ca-key.pem \
        -config=config.json \
        -profile=peer \
        hosts/consul.csr.json | cfssljson -bare consul
    ```
3. Those command will produce:
    * consul.pem (Public Key)
    * consul-key.pem (Private Key) => We will need later for renew the certificate
    * consul.csr (Certificate Signing Request) => We will need later for renew the certificate
4. In case Client/Host certificate is expired, prepare the private key and CSR, then run below command:
    ```bash
    $ cfssl sign -ca=ca.pem \
        -ca-key=ca-key.pem \
        -config=config.json \
        -profile=peer \
        -csr=consul.csr | cfssljson -bare consul
    ```


### References
1. [how-to-use-cfssl-to-create-self-signed-certificates](https://medium.com/@rob.blackbourn/how-to-use-cfssl-to-create-self-signed-certificates-d55f76ba5781)