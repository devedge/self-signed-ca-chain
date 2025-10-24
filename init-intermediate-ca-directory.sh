INTERMEDIATE_CA_PATH="intermediate-ca"
mkdir -p ${INTERMEDIATE_CA_PATH}/{certs,crl,csr,newcerts,private}
chmod 700 ${INTERMEDIATE_CA_PATH}/private
touch ${INTERMEDIATE_CA_PATH}/index.txt
echo 1000 > ${INTERMEDIATE_CA_PATH}/serial
echo 1000 > ${INTERMEDIATE_CA_PATH}/crlnumber
