# self-signed-ca-chain

__Self-Signed Certificate Authority Chain Framework__

This repository is a templated framework to guide the creation of a self-signed certificate authority using `openssl`, along with intermediate certificates and leaf certificates.

```
export ROOT_CA_NAME="root-ca"
export INTERMEDIATE_CA_NAME="intermediate-ca"
```

```
openssl genrsa -aes256 -out $ROOT_CA_NAME/private/$ROOT_CA_NAME.key.pem 4096
chmod 400 $ROOT_CA_NAME/private/$ROOT_CA_NAME.key.pem
```

```
openssl req -config self-signed-ca-chain_openssl.cnf -x509 -extensions v3_ca \
      -new -days 7300 \
      -key $ROOT_CA_NAME/private/$ROOT_CA_NAME.key.pem \
      -out $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem
chmod 444 $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem
openssl x509 -noout -text -in $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem | less
```

```
openssl genrsa -aes256 -out $INTERMEDIATE_CA_NAME/private/$INTERMEDIATE_CA_NAME.key.pem 4096
chmod 400 $INTERMEDIATE_CA_NAME/private/$INTERMEDIATE_CA_NAME.key.pem
```

```
openssl req -config self-signed-ca-chain_openssl.cnf -new \
    -key $INTERMEDIATE_CA_NAME/private/$INTERMEDIATE_CA_NAME.key.pem \
    -out $INTERMEDIATE_CA_NAME/csr/$INTERMEDIATE_CA_NAME.csr.pem
```

```
openssl ca -config self-signed-ca-chain_openssl.cnf -name $ROOT_CA_NAME -extensions v3_intermediate_ca \
    -days 3650 -notext \
    -in $INTERMEDIATE_CA_NAME/csr/$INTERMEDIATE_CA_NAME.csr.pem \
    -out $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem
chmod 444 $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem
openssl x509 -noout -text -in $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem | less
openssl verify -CAfile $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem
cat $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem > $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME-chain.cert.pem
```

```
openssl genrsa -aes256 -out $INTERMEDIATE_CA_NAME/private/www.example.com.key.pem 2048
chmod 400 $INTERMEDIATE_CA_NAME/private/www.example.com.key.pem
```

```
openssl req -config self-signed-ca-chain_openssl.cnf -new \
    -key $INTERMEDIATE_CA_NAME/private/www.example.com.key.pem \
    -out $INTERMEDIATE_CA_NAME/csr/www.example.com.csr.pem
```

```
openssl ca -config self-signed-ca-chain_openssl.cnf -name $INTERMEDIATE_CA_NAME -extensions server_cert \
    -days 375 -notext \
    -in $INTERMEDIATE_CA_NAME/csr/www.example.com.csr.pem \
    -out $INTERMEDIATE_CA_NAME/certs/www.example.com.cert.pem
chmod 444 $INTERMEDIATE_CA_NAME/certs/www.example.com.cert.pem
openssl x509 -noout -text -in $INTERMEDIATE_CA_NAME/certs/www.example.com.cert.pem | less
openssl verify -CAfile $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME-chain.cert.pem $INTERMEDIATE_CA_NAME/certs/www.example.com.cert.pem
```
