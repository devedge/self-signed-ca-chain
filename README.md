# self-signed-ca-chain

__Self-Signed Certificate Authority Chain Framework__

This repository is a templated framework to guide the creation of a self-signed certificate authority using `openssl`, along with intermediate certificates and leaf certificates.

---

__Methodology__

`openssl` is a complicated program with many different ways of achieving the same results. Therefore, this guide follows a specific strategy to simplify and standardize the creation of an entire TLS certificate authority chain.

The configuration file, `self-signed-ca-chain_openssl.cnf`, is considered the single source of truth for the entire CA chain. The shell environment variables `ROOT_CA_NAME`, `INTERMEDIATE_CA_NAME`, and `SAN_SECTION` are used to both define values in the configuration file and for the following command-line arguments to avoid re-typing the exact same directories/filenames repeatedly.

```bash
export ROOT_CA_NAME="root-ca"
export INTERMEDIATE_CA_NAME="intermediate-ca"
export SAN_SECTION="@san_example"
```

The root CA and intermediate CA values are used to create the subdirectories and the key/cert/crl filenames. For example, if the following values are defined:

```bash
export ROOT_CA_NAME="root-ca-devedge"
export INTERMEDIATE_CA_NAME="intermediate-ca-fedora"
export SAN_SECTION="@san_example"
```

the two following scripts are run:

```bash
./init-root-ca-directory.sh
./init-intermediate-ca-directory.sh
```

and all the following `openssl` commands in the next section are run to create a root CA, intermediate CA, and a leaf certificate for `www.example.com`, then the subsequent file directories will look like this:

```
.
├── init-intermediate-ca-directory.sh
├── init-root-ca-directory.sh
├── intermediate-ca-fedora
│   ├── certs
│   │   ├── intermediate-ca-fedora-chain.cert.pem
│   │   ├── intermediate-ca-fedora.cert.pem
│   │   └── www.example.com.cert.pem
│   ├── crl
│   ├── crlnumber
│   ├── csr
│   │   ├── intermediate-ca-fedora.csr.pem
│   │   └── www.example.com.csr.pem
│   ├── index.txt
│   ├── index.txt.attr
│   ├── index.txt.old
│   ├── newcerts
│   │   └── 1000.pem
│   ├── private
│   │   ├── intermediate-ca-fedora.key.pem
│   │   └── www.example.com.key.pem
│   ├── serial
│   └── serial.old
├── root-ca-devedge
│   ├── certs
│   │   └── root-ca-devedge.cert.pem
│   ├── crl
│   ├── index.txt
│   ├── index.txt.attr
│   ├── index.txt.old
│   ├── newcerts
│   │   └── 1000.pem
│   ├── private
│   │   └── root-ca-devedge.key.pem
│   ├── serial
│   └── serial.old
└── self-signed-ca-chain_openssl.cnf
```

The workflow will look like this:

For the root CA:

    - use `openssl genrsa` to create a private key
    - use `openssl req` to generate a self-signed certificate

For the intermediate CA:

    - use `openssl genrsa` to create a private key
    - use `openssl req` to create a certificate signing request (CSR)
    - use `openssl ca` to create the intermediate CA's certificate, using the root CA's configuration

For subsequent leaf certificates:

    - use `openssl genrsa` to create a private key
    - use `openssl req` to create a certificate signing request (CSR)
    - use `openssl ca` to create the leaf certificate, using the intermediate CA's configuration


## Generate the root CA

Create a private key for the root CA and set it as read-only for only the user:

```bash
openssl genrsa -aes256 -out $ROOT_CA_NAME/private/$ROOT_CA_NAME.key.pem 4096
chmod u=r,go= $ROOT_CA_NAME/private/$ROOT_CA_NAME.key.pem
```

Use the `openssl req` command with the `-x509` flag to instantly create a self-signed certificate. Use the `v3_ca` extensions with `-extensions v3_ca` to use the extensions for a typical CA defined in the configuration file section `[ v3_ca ]`:

```bash
openssl req -config self-signed-ca-chain_openssl.cnf -x509 -extensions v3_ca \
      -new \
      -days 7300 \
      -key $ROOT_CA_NAME/private/$ROOT_CA_NAME.key.pem \
      -out $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem
```

Set the certificate file to be read-only for everyone:

```bash
chmod ugo=r $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem
```

This certificate can be inspected with the `openssl x509 -text` subcommand:

```bash
openssl x509 -noout -text -in $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem
```


## Generate the intermediate CA

Create a private key for the intermediate CA and set it as read-only for only the user:

```bash
openssl genrsa -aes256 -out $INTERMEDIATE_CA_NAME/private/$INTERMEDIATE_CA_NAME.key.pem 4096
chmod u=r,go= $INTERMEDIATE_CA_NAME/private/$INTERMEDIATE_CA_NAME.key.pem
```

Create a certificate signing request for the intermediate CA. The root CA will use this to create a certificate:

```bash
openssl req -config self-signed-ca-chain_openssl.cnf \
    -new \
    -key $INTERMEDIATE_CA_NAME/private/$INTERMEDIATE_CA_NAME.key.pem \
    -out $INTERMEDIATE_CA_NAME/csr/$INTERMEDIATE_CA_NAME.csr.pem
```

Sign the intermediate CA's CSR using the root CA's configuration in the `openssl` configuration file (`-name root_ca`). Additionally, specify the extensions for a typical intermediate CA using the `-extensions v3_intermediate_ca` flag, which reads the `[ v3_intermediate_ca ]` section in the configuration file:

```bash
openssl ca -config self-signed-ca-chain_openssl.cnf -name root_ca -extensions v3_intermediate_ca \
    -days 3650 \
    -notext \
    -in $INTERMEDIATE_CA_NAME/csr/$INTERMEDIATE_CA_NAME.csr.pem \
    -out $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem
```

Set the certificate file to be read-only for everyone:

```bash
chmod ugo=r $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem
```

The certificate can be inspected:

```bash
openssl x509 -noout -text -in $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem | less
```

And the certificate can also be verified with the `openssl verify` subcommand:

```bash
openssl verify -CAfile $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem
```

If needed, you can create a certificate chain file with both the root CA and the intermediate CA's certificates. This can be used to provide a full certificate chain if you have not added the root CA's certificate to your computer's certificate store:

```bash
cat $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME.cert.pem $ROOT_CA_NAME/certs/$ROOT_CA_NAME.cert.pem > $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME-chain.cert.pem
```


## Generate a leaf certificate

Create a private key for a certificate for `www.example.com` and set it as read-only for only the user:

```bash
openssl genrsa -aes256 -out $INTERMEDIATE_CA_NAME/private/www.example.com.key.pem 2048
chmod u=r,go= $INTERMEDIATE_CA_NAME/private/www.example.com.key.pem
```

Again, create a certificate signing request:

```bash
openssl req -config self-signed-ca-chain_openssl.cnf \
    -new \
    -key $INTERMEDIATE_CA_NAME/private/www.example.com.key.pem \
    -out $INTERMEDIATE_CA_NAME/csr/www.example.com.csr.pem
```

Now, sign this CSR with the intermediate CA, specified with `-name intermediate_ca`. Use the `server_cert` extention in the configuration file to create a valid certificate for a TLS web server.

Additionally, the `SAN_SECTION` variable is read here. This will use the `[ san_example ]` section in the `openssl` config file to add the specified Subject Alternative Names to the certificate:

```bash
openssl ca -config self-signed-ca-chain_openssl.cnf -name intermediate_ca -extensions server_cert \
    -days 375 \
    -notext \
    -in $INTERMEDIATE_CA_NAME/csr/www.example.com.csr.pem \
    -out $INTERMEDIATE_CA_NAME/certs/www.example.com.cert.pem
```

Set the certificate to be read-only for all users:

```bash
chmod ugo=r $INTERMEDIATE_CA_NAME/certs/www.example.com.cert.pem
```

And it can be inspected:

```bash
openssl x509 -noout -text -in $INTERMEDIATE_CA_NAME/certs/www.example.com.cert.pem
```

Or even verified against the certificate chain file:

```bash
openssl verify -CAfile $INTERMEDIATE_CA_NAME/certs/$INTERMEDIATE_CA_NAME-chain.cert.pem $INTERMEDIATE_CA_NAME/certs/www.example.com.cert.pem
```
