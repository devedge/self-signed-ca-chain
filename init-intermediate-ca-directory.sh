# Type the following before running:
# export INTERMEDIATE_CA_NAME="intermediate-ca"

mkdir -p "${INTERMEDIATE_CA_NAME}/{certs,crl,csr,newcerts,private}"
chmod 700 "${INTERMEDIATE_CA_NAME}/private"
touch "${INTERMEDIATE_CA_NAME}/index.txt"

# Prevent accidentally overwriting the serial or crlnumber files
if [ ! -f "${INTERMEDIATE_CA_NAME}/serial" ]; then
    echo 1000 > "${INTERMEDIATE_CA_NAME}/serial"
fi

if [ ! -f "${INTERMEDIATE_CA_NAME}/crlnumber" ]; then
    echo 1000 > "${INTERMEDIATE_CA_NAME}/crlnumber"
fi
