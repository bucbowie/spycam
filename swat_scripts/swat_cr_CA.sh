#!/usr/bin/bash
# name: swat_cr_CA.sh
# desc: Create certificate for SSL/TLS
# usage: ./swat_cr_CA.sh
#
export MY_SCRIPT=swat_cr_CA.sh
export SERVER_CA_DIR=/usr/share/ca-certificates
export MY_CA_DIR="${SERVER_CA_DIR}"/extras
export MY_CA_ROOT_DIR=/etc/swat/conf.d/CA
export MY_PRIVATE_CA_ROOT_DIR="${MY_CA_ROOT_DIR}"/private
export MY_CA_ROOT_PASS_PHRASE=`cat /proc/cpuinfo|grep Serial|awk '{print $NF}'`
export SWAT_INSTALL_DIR=/home/swat/swat_install
export MY_ROOT_CERT="swatCA"
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
 MY_SCRIPT_DIR="/home/swat/swat_scripts"
 [[ -f /boot/swat.config ]] && { . /boot/swat.config; }
 [[ -f "${MY_SCRIPT_DIR}"/boot/swat.config ]] && { . "${MY_SCRIPT_DIR}"/boot/swat.config; }
  
 [[ ! -d "${MY_CA_ROOT_DIR}" ]] && { allocate_dirs "${MY_CA_ROOT_DIR}"; }
 [[ ! -d "${MY_PRIVATE_CA_ROOT_DIR}" ]] && { allocate_dirs "${MY_PRIVATE_CA_ROOT_DIR}"; }
 [[ ! -d "${MY_CA_DIR}" ]] && { allocate_dirs "${MY_CA_DIR}"; } 
 cd "${MY_CA_ROOT_DIR}"
 if [[ -f "${MY_CA_ROOT_DIR}"/openssl.cnf ]];then
   {
     export OPENSSL_DIR="${MY_CA_ROOT_DIR}"
   }
 elif [[ ! -f "${MY_SCRIPT_DIR}"/openssl.cnf ]];then
   {
	echo "###################################"
	echo "# W A R N I N G !                  "
	echo "# - - - - - - - - - - - - - - - - -"
	echo "# Error in ${MY_SCRIPT}!           "
	echo "# Unable to find ${MY_SCRIPT_DIR}/openssl.cnf "
	echo "# Aborting with no action taken."
	echo "# No certificate will be generated..."
	echo "# ...if you desire SSL/TLS, then you"
	echo "# will have to manually create certificate."
	sleep 5
	exit 4
   }
 else
   {
     sudo mv "${MY_SCRIPT_DIR}"/openssl.cnf  "${MY_CA_ROOT_DIR}"/openssl.cnf
     export OPENSSL_DIR="${MY_CA_ROOT_DIR}"
     if [[ ! -z "${MY_EMAIL_ADDRESS}" ]];then
       {
	 sudo sed -i.bak '/emailAddress_default/s/emailAddress_default\s*=\s.*$/emailAddress_default            = '"${MY_EMAIL_ADDRESS}"'/' "${MY_CA_ROOT_DIR}"/openssl.cnf 
       }
     fi
   }
 fi
 if [[ ! -f "${MY_PRIVATE_CA_ROOT_DIR}"/cakey.pem ]];then
   {
     echo "# - - - - - - - - - - - - - - - - -"
     echo "# Generate genrsa cakey.pem to avoid PASSPHRASE"
     echo "# - - - - - - - - - - - - - - - - -"
     sleep 2
     sudo openssl genrsa  -out ${MY_PRIVATE_CA_ROOT_DIR}/cakey.pem 4096 
     [[ -f  ${MY_PRIVATE_CA_ROOT_DIR}/cakey.pem  ]] && { sudo chmod 400 "${MY_PRIVATE_CA_ROOT_DIR}"/cakey.pem; } 
   }
 fi
 echo "###################################"
 echo "# I N F O R M A T I O N A L        "
 echo "# - - - - - - - - - - - - - - - - -"
 echo "# ${MY_SCRIPT} validating ${MY_PRIVATE_CA_ROOT_DIR}/cakey.pem"
 echo "###################################"
 sleep 3
 sudo openssl rsa -in "${MY_PRIVATE_CA_ROOT_DIR}"/cakey.pem -check|head -4
 sleep 2
 echo "# - - - - - - - - - - - - - - - - -"
 echo "# Generate Certificate Root Authority"
 echo "# - - - - - - - - - - - - - - - - -"
 sleep 2
 set -aevx
 MY_STRING="req -config ${OPENSSL_DIR}/openssl.cnf -new -key ${MY_PRIVATE_CA_ROOT_DIR}/cakey.pem -x509 -days 366 -sha256 -extensions v3_ca -out ${MY_CA_ROOT_DIR}/${MY_ROOT_CERT}.pem"

 for i in 1 
   do
     echo "





`hostname`
     "|sudo openssl `echo "${MY_STRING}"`;done 
 myRC=$?
 set +evx
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "###################################"
     echo "# E R R O R !                      "
     echo "# - - - - - - - - - - - - - - - - -"
     echo "# Error in ${MY_SCRIPT}!           "
     echo "# Unable to create ${MY_CA_ROOT_DIR}/${MY_ROOT_CERT}.pem"
     echo "# ...Needed to create ROOT CA ${MY_ROOT_CERT}.crt"
     echo "# ---> Aborting script with no action taken."
     echo "# ---> Processing continues, but may impact using TLS/SSL"
     echo "# ---> for HTTPS:// connections.   "
     echo "###################################"
     exit 4
    }
 fi
 echo " "
 echo "###################################"
 echo "# I N F O R M A T I O N A L        "
 echo "# - - - - - - - - - - - - - - - - -"
 echo "# ${MY_SCRIPT} validating ${MY_CA_ROOT_DIR}/${MY_ROOT_CERT}.pem"
 echo "###################################"
 if [[ ${myRC} -eq 0 ]];then
   {
     echo "###################################"
     echo "# I N F O R M A T I O N A L        "
     echo "# - - - - - - - - - - - - - - - - -"
     echo "# ${MY_SCRIPT} refreshing CERTIFICATES"
     echo "# and perparing to install: ${SERVER_CA_DIR}/${MY_ROOT_CERT}.crt"
     echo "# - - - - - - - - - - - - - - - - -"
     if [[ ( -f "${SERVER_CA_DIR}"/${MY_ROOT_CERT}.crt ) && ( -f "${MY_CA_ROOT_DIR}"/${MY_ROOT_CERT}.pem ) ]]; then
       {
          sudo rm -f "${SERVER_CA_DIR}"/${MY_ROOT_CERT}.crt
          sudo update-ca-certificates --fresh
       }
     fi
     sudo cp "${MY_CA_ROOT_DIR}"/${MY_ROOT_CERT}.pem "${MY_CA_DIR}"/${MY_ROOT_CERT}.crt
     sudo cp "${MY_CA_ROOT_DIR}"/${MY_ROOT_CERT}.pem "${SERVER_CA_DIR}"/${MY_ROOT_CERT}.crt
     myCNT=`grep ^${MY_ROOT_CERT}.crt /etc/ca-certificates.conf|wc -l`
     [[ ${myCNT} -eq 0 ]] && { sudo echo "${MY_ROOT_CERT}.crt" >> /etc/ca-certificates.conf; }
     sudo dpkg-reconfigure -p critical ca-certificates
     sudo update-ca-certificates
     sudo c_rehash /etc/ssl/certs
  }
 fi
 sleep 3
 echo "###################################"
 echo "# I N F O R M A T I O N A L        "
 echo "# - - - - - - - - - - - - - - - - -"
 echo "# ${MY_SCRIPT} validating ${SERVER_CA_DIR}/${MY_ROOT_CERT}.crt"
 echo "###################################"
 openssl verify "${SERVER_CA_DIR}"/${MY_ROOT_CERT}.crt | tee -a /var/log/swat.log
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "###################################"
     echo "# W A R N I N G !                  "
     echo "# - - - - - - - - - - - - - - - - -"
     echo "# Error in ${MY_SCRIPT}!           "
     echo "# Unable to correctly install ${SERVER_CA_DIR}/${MY_ROOT_CERT}.crt"
     echo "# Processing continues, but may impact using TLS/SSL"
     echo "# for HTTPS:// connections.       "
     echo "###################################"
     sleep 3
   }
 else
   {
     sudo openssl x509 -in "${SERVER_CA_DIR}"/${MY_ROOT_CERT}.crt -noout -text|head -10|tee -a /var/log/swat.log
     sleep 3
     sudo openssl x509 -in "${SERVER_CA_DIR}"/${MY_ROOT_CERT}.crt -noout -purpose|grep SSL | tee -a /var/log/swat.log
     sleep 3
   }
 fi
