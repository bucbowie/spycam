#!/usr/bin/bash
# name: swat_cr_cert.sh
# desc: Create certificate for SSL/TLS
# usage: ./swat_cr_cert.sh
#
export MY_SCRIPT=swat_cr_cert.sh
export MY_CERT_DIR=/etc/swat/conf.d/CA
export MY_NEW_CERT_DIR=/etc/swat/conf.d/CA/newcerts
export MY_PRIVATE_CERT_DIR="${MY_CERT_DIR}"/private
export MY_CSR_CERT_DIR="${MY_CERT_DIR}"/csr
export MY_CERT_PASS_PHRASE=`cat /proc/cpuinfo|grep Serial|awk '{print $NF}'`
export SWAT_INSTALL_DIR=/home/swat/swat_install
export SERVER=`hostname`
#------------------------------------------#
 function allocate_dirs() {
#------------------------------------------#
    MY_DIR=$1
    sudo mkdir -p "${MY_DIR}"
    myRC=$?
    if [[ ${myRC} -ne 0 ]];then
      {
	echo "###################################"
	echo "# Error in ${MY_SCRIPT}!           "
	echo "# Unable to create directory ${MY_DIR}. "
	echo "# Aborting ${MY_SCRIPT} with no action taken."
	echo "#---------------------------------#"
	exit 8
      }
    fi
 sudo chown root:sudo "${MY_DIR}"
 sudo chmod 750 "${MY_DIR}"

 return 0
}
##############################################
# MAIN LOGIC STARTS HERE
##############################################
 export SCRIPT_DIR="/home/swat/swat_scripts"
 [[ -f /boot/swat.config ]] && { . /boot/swat.config; }
 [[ -f "${SCRIPT_DIR}"/boot/swat.config ]] && { . "${SCRIPT_DIR}"/boot/swat.config; }
  
 [[ ! -d "${MY_CERT_DIR}" ]] && { allocate_dirs "${MY_CERT_DIR}"; }
 [[ ! -d "${MY_NEW_CERT_DIR}" ]] && { allocate_dirs "${MY_NEW_CERT_DIR}"; }
 [[ ! -d "${MY_PRIVATE_CERT_DIR}" ]] && { allocate_dirs "${MY_PRIVATE_CERT_DIR}"; }
 [[ ! -d "${MY_CSR_CERT_DIR}" ]] && { allocate_dirs "${MY_CSR_CERT_DIR}"; }
 cd "${MY_CERT_DIR}"
 [[ ! -f "${MY_CERT_DIR}"/index.txt ]] && { sudo touch "${MY_CERT_DIR}"/index.txt; }
 [[ ! -f "${MY_CERT_DIR}"/serial ]] && { sudo echo 01 > "${MY_CERT_DIR}"/serial; }

 if [[ -f "${MY_CERT_DIR}"/openssl.cnf ]];then
   {
     export OPENSSL_DIR="${MY_CERT_DIR}"
   }
 elif [[ ! -f "${SCRIPT_DIR}"/openssl.cnf ]];then
   {
	echo "###################################"
	echo "# W A R N I N G !                  "
	echo "# - - - - - - - - - - - - - - - - -"
	echo "# Error in ${MY_SCRIPT}!           "
	echo "# Unable to find ${SCRIPT_DIR}/openssl.cnf "
	echo "# Aborting with no action taken."
	echo "# No certificate will be generated..."
	echo "# ...if you desire SSL/TLS, then you"
	echo "# will have to manually create certificate."
	sleep 5
	exit 4
   }
 else
   {
     sudo mv "${SCRIPT_DIR}"/openssl.cnf  "${MY_CERT_DIR}"/openssl.cnf
     export OPENSSL_DIR="${MY_CERT_DIR}"
     if [[ ! -z "${MY_EMAIL_ADDRESS}" ]];then
       {
	 sudo sed -i.bak '/emailAddress_default/s/emailAddress_default\s*=\s.*$/emailAddress_default            = '"${MY_EMAIL_ADDRESS}"'/' "${MY_CERT_DIR}"/openssl.cnf 
       }
     fi
   }
 fi
 if [[ ! -f "${MY_PRIVATE_CERT_DIR}"/${SERVER}.key ]];then 
   {
     echo "# - - - - - - - - - - - - - - - - -"
     echo "# Generate genrsa ${SERVER}.key to avoid PASSPHRASE"
     echo "# - - - - - - - - - - - - - - - - -"
     sudo openssl genrsa -out ${MY_PRIVATE_CERT_DIR}/${SERVER}.key 
   }
 fi
 echo "###################################"
 echo "# I N F O R M A T I O N A L        "
 echo "# - - - - - - - - - - - - - - - - -"
 echo "# ${MY_SCRIPT} validating ${MY_PRIVATE_CERT_DIR}/${SERVER}.key"
 echo "###################################"
 openssl rsa -in "${MY_PRIVATE_CERT_DIR}"/${SERVER}.key -check|head -4
 sleep 2

 echo "# - - - - - - - - - - - - - - - - -"
 echo "# Generate Certificate Request     "
 echo "# - - - - - - - - - - - - - - - - -"
 sleep 2
 MY_CSR_BUILD_STRING="req  -config ${OPENSSL_DIR}/openssl.cnf -new -key ${MY_PRIVATE_CERT_DIR}/${SERVER}.key -out ${MY_CSR_CERT_DIR}/${SERVER}.csr"

 for i in 1 
   do
     echo "





`hostname`
     "|sudo openssl `echo "${MY_CSR_BUILD_STRING}"`;done 
 echo " "
 echo "###################################"
 echo "# I N F O R M A T I O N A L        "
 echo "# - - - - - - - - - - - - - - - - -"
 echo "# ${MY_SCRIPT} validating ${MY_CSR_CERT_DIR}/${SERVER}.csr"
 echo "###################################"
 sleep 2
 openssl req -text -noout -verify -in "${MY_CSR_CERT_DIR}"/${SERVER}.csr|head -10|tee -a /var/log/swat.log
 sleep 2
 
 echo "# - - - - - - - - - - - - - - - - -"
 echo "# Generate and Sign Certificate    "
 echo "# - - - - - - - - - - - - - - - - -"
 sleep 2
 MY_CERT_BUILD_STRING=" ca -config ${OPENSSL_DIR}/openssl.cnf -extensions server_cert -days 366 -notext -md sha256  -in ${MY_CSR_CERT_DIR}/${SERVER}.csr -out ${MY_CERT_DIR}/${SERVER}.crt"
  
 for i in 1 
   do
     echo "y
y
     "|sudo openssl `echo "${MY_CERT_BUILD_STRING}"`;done 
 echo "###################################"
 echo "# I N F O R M A T I O N A L        "
 echo "# - - - - - - - - - - - - - - - - -"
 echo "# ${MY_SCRIPT} validating ${MY_CERT_DIR}/${SERVER}.crt"
 echo "###################################"
 sleep 3
 sudo openssl x509 -in "${MY_CERT_DIR}"/${SERVER}.crt -text -noout|head -13|tee -a /var/log/swat.log
