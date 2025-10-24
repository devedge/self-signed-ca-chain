ROOT_CA_PATH="root-ca"
mkdir -p ${ROOT_CA_PATH}/{certs,crl,newcerts,private}
chmod 700 ${ROOT_CA_PATH}/private
touch ${ROOT_CA_PATH}/index.txt
echo 1000 > ${ROOT_CA_PATH}/serial
