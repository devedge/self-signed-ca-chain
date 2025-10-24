# self-signed-ca-chain

__Self-Signed Certificate Authority Chain Framework__

This repository is a templated framework to guide the creation of a self-signed certificate authority, along with intermediate certificates and leaf certificates.

```
openssl genrsa -aes256 -out root-ca/private/ca.key.pem 4096
chmod 400 root-ca/private/ca.key.pem
```

```
openssl req -config self-signed-ca-chain-openssl.cnf -x509 -extensions v3_ca \
      -new -days 7300 -sha256 \
      -key root-ca/private/ca.key.pem \
      -out root-ca/certs/ca.cert.pem
chmod 444 root-ca/certs/ca.cert.pem
openssl x509 -noout -text -in root-ca/certs/ca.cert.pem | less
```

```
openssl genrsa -aes256 -out intermediate-ca/private/intermediate.key.pem 4096
chmod 400 intermediate-ca/private/intermediate.key.pem
```

```
openssl req -config self-signed-ca-chain-openssl.cnf \
    -new -sha256 \
    -key intermediate-ca/private/intermediate.key.pem \
    -out intermediate-ca/csr/intermediate.csr.pem
```

```
openssl ca -config self-signed-ca-chain-openssl.cnf -name root_ca -extensions v3_intermediate_ca \
    -days 3650 -notext -md sha256 \
    -in intermediate-ca/csr/intermediate.csr.pem \
    -out intermediate-ca/certs/intermediate.cert.pem
chmod 444 intermediate-ca/certs/intermediate.cert.pem
openssl x509 -noout -text -in intermediate-ca/certs/intermediate.cert.pem | less
openssl verify -CAfile root-ca/certs/ca.cert.pem intermediate-ca/certs/intermediate.cert.pem
cat intermediate-ca/certs/intermediate.cert.pem root-ca/certs/ca.cert.pem > intermediate-ca/certs/intermediate-ca-chain.cert.pem
```

```
openssl genrsa -aes256 -out intermediate-ca/private/www.example.com.key.pem 2048
chmod 400 intermediate-ca/private/www.example.com.key.pem
```

```
openssl req -config self-signed-ca-chain-openssl.cnf \
    -new -sha256 \
    -key intermediate-ca/private/www.example.com.key.pem \
    -out intermediate-ca/csr/www.example.com.csr.pem
```

```
openssl ca -config self-signed-ca-chain-openssl.cnf -name intermediate_ca -extensions server_cert \
    -days 375 -notext -md sha256 \
    -in intermediate-ca/csr/www.example.com.csr.pem \
    -out intermediate-ca/certs/www.example.com.cert.pem
chmod 444 intermediate-ca/certs/www.example.com.cert.pem
openssl x509 -noout -text -in intermediate-ca/certs/www.example.com.cert.pem | less
openssl verify -CAfile intermediate-ca/certs/intermediate-ca-chain.cert.pem intermediate-ca/certs/www.example.com.cert.pem
```
