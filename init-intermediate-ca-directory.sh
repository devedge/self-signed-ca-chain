# Type the following before running:
# export INTERMEDIATE_CA_NAME="intermediate-ca"
mkdir -p ${INTERMEDIATE_CA_NAME}/{certs,crl,csr,newcerts,private}
chmod 700 ${INTERMEDIATE_CA_NAME}/private
touch ${INTERMEDIATE_CA_NAME}/index.txt
echo 1000 > ${INTERMEDIATE_CA_NAME}/serial
echo 1000 > ${INTERMEDIATE_CA_NAME}/crlnumber
