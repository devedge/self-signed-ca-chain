# Type the following before running:
# export ROOT_CA_NAME="root-ca"
mkdir -p ${ROOT_CA_NAME}/{certs,crl,newcerts,private}
chmod 700 ${ROOT_CA_NAME}/private
touch ${ROOT_CA_NAME}/index.txt
echo 1000 > ${ROOT_CA_NAME}/serial
