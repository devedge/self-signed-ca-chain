# Type the following before running:
# export ROOT_CA_NAME="root-ca"
# export INTERMEDIATE_CA_NAME="intermediate-ca"

rm -f ${ROOT_CA_NAME}/{certs,crl,newcerts,private}/*
rm -f ${ROOT_CA_NAME}/{index*,serial*}
echo 1000 > ${ROOT_CA_NAME}/serial
echo > ${ROOT_CA_NAME}/index.txt

rm -f ${INTERMEDIATE_CA_NAME}/{certs,crl,csr,newcerts,private}/*
rm -f ${INTERMEDIATE_CA_NAME}/{index*,serial*}
echo 1000 > ${INTERMEDIATE_CA_NAME}/crlnumber
echo 1000 > ${INTERMEDIATE_CA_NAME}/serial
echo > ${INTERMEDIATE_CA_NAME}/index.txt
