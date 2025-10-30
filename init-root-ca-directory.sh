# Type the following before running:
# export ROOT_CA_NAME="root-ca"

mkdir -p ${ROOT_CA_NAME}/{certs,crl,newcerts,private}
chmod 700 ${ROOT_CA_NAME}/private
touch ${ROOT_CA_NAME}/index.txt

# Prevent accidentally overwriting the serial file
if [ ! -f ${ROOT_CA_NAME}/serial ]; then
    echo 1000 > ${ROOT_CA_NAME}/serial
fi
