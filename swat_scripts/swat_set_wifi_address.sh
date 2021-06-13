#!/usr/bin/bash
# name: swat_set_wifi_address.sh
# desc: Assign STATIC IP to wireless or wlan0 IP
# usage: ./swat_set_wifi_address.sh
# 2018.03.18 Add tee to /etc/dhcpcd.conf          #Askew20180318.002
#            and add more error displays          #Askew20180218.001
#
set -a
 export MY_SCRIPT="swat_set_wifi_address.sh"
 export SCRIPT_DIR=/home/swat/swat_scripts
 [[ -f "${SCRIPT_DIR}"/swat.config ]] && { . "${SCRIPT_DIR}"/swat.config; }
 myRC=$?
 if [[ ${myRC} -ne 0 ]]; then
   {
     echo "#######################################"
     echo "# ${MY_SCRIPT} unable to load ${SCRIPT_DIR}/swat.config" 
     echo "# Aborting with no action taken.      "
     echo "# - - - - - - - - - - - - - - - - - - #"
     echo "# Your wireless IP address will not be"
     echo "# changed by this script.             "
     echo "# Please review ${SCRIPT_DIR}/swat.config"
     echo "# Does it exist and is it accessible? "
     echo "# There are arguments needed by this script."
     echo "# Review /boot/swat.config for argument: MY_SERVER_WIFI_IP"
     echo "# and make adjustments accordingly to    "
     echo "# match your desire wireless IP.         "
     echo "# - - - - - - - - - - - - - - - - - - #"
     echo "# Returning to install.sh to continue."
     echo "#------------------------------------#"
     exit 4
   }
 fi
 export MY_CONFIG_WIFI_IP="${MY_SERVER_WIFI_IP}"
 if [[ ! -z "${MY_SERVER_WIFI_IP}" ]];then
   {
     echo "#######################################"
     echo "# ${MY_SCRIPT} found swat.config      "
     echo "# contained MY_CONFIG_WIFI_IP=${MY_CONFIG_WIFI_IP}"
     echo "# --> Setting WIFI to ${MY_CONFIG_WIFI_IP}"
     echo "#------------------------------------#"
  }
 else
   {
     export MY_NEW_WIFI_ADDRESS=`${SCRIPT_DIR}/swat_get_wifi_address.sh`
     myRC=$?
     if [[ ( ${myRC} -ne 0 ) || (  -z "${MY_NEW_WIFI_ADDRESS}" )  ]];then
       {
	     echo "#######################################"
	     echo "# ${MY_SCRIPT} unable to set MY_NEW_WIFI_ADDRESS using ${MY_NEW_WIFI_ADDRESS}" 
	     echo "# Aborting with no action taken.       "
	     echo "# - - - - - - - - - - - - - - - - - - #"
	     echo "# Either MY_NEW_WIFI_ADDRESS failed to be set,"
	     echo "# or                                   "
	     echo "# ${SCRIPT_DIR}/swat_get_wifi_address.sh"
	     echo "# had issues or was not found in ${SCRIPT_DIR}"
	     echo "#-------------------------------------#"
	     exit 4
       }
     fi
     sudo sed -i.bak '/MY_SERVER_WIFI_IP/s/MY_SERVER_WIFI_IP=\"\"/MY_SERVER_WIFI_IP=\"'"${MY_NEW_WIFI_ADDRESS}"'\"/' /boot/swat.config
     myRC=$?
     if [[ ${myRC} -ne 0 ]]; then
	   {
	     echo "#######################################"
	     echo "# ${MY_SCRIPT} found MY_NEW_WIFI_ADDRESS=${MY_NEW_WIFI_ADDRESS}" 
	     echo "# but unable to modify /boot/swat.config."
	     echo "# Aborting ${MY_SCRIPT} during execution."
	     echo "# - - - - - - - - - - - - - - - - - - #"
	     echo "# Review /boot/swat.config for argument: MY_SERVER_WIFI_IP"
	     echo "# and make adjustments accordingly to    "
	     echo "# match your desire wireless IP.         "
	     echo "#---------------------------------------#"
	     exit 0
	   }
    fi
   }
fi

 myCNT=`cat /etc/dhcpcd.conf|grep -v ^\#|grep wlan0|wc -l` 
 if [[ ${myCNT} -ne 0 ]]; then
   {
     echo "#######################################"
     echo "# ${MY_SCRIPT} found existing entry for"
     echo "# wlan0 in /etc/dhcpcd.conf.           "
     echo "# Aborting ${MY_SCRIPT} in paragraph   "
     echo "# setting /etc/dhcpcd.conf.            "
     echo "# Please review /etc/dhcpcd.conf and   "
     echo "# ensure your wlan0 is set up correctly."
     echo "#-------------------------------------#"
     exit 0
   }
 fi

 sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.pristine

 echo " interface ${WIFI_DEVICE}" >> /etc/dhcpcd.conf
 if [[ ! -z "${MY_CONFIG_WIFI_IP}" ]]; then
   {
     echo " static ip_address=${MY_CONFIG_WIFI_IP}/24"|tee -a  /etc/dhcpcd.conf #Askew20180318.001
   }
 else
   {
     echo " static ip_address=${MY_NEW_WIFI_ADDRESS}/24"| tee -a  /etc/dhcpcd.conf
   }
 fi
 echo " static routers=${MY_ROUTER_IP}"|tee -a  /etc/dhcpcd.conf 
 echo " static domain_name_servers=${MY_ROUTER_IP}"|tee -a  /etc/dhcpcd.conf 
 echo " static domain_name_servers=8.8.8.8"|tee -a /etc/dhcpcd.conf 
 echo " static domain_name_servers=8.8.4.4"|tee -a /etc/dhcpcd.conf 

 echo -e "From: `hostname`\nNOTE:Camera will be active after NEXT REBOOT."|sudo mail -s "Cam web address: ${MY_NEW_WIFI_ADDRESS}/cam/"  "${MY_EMAIL_ADDRESS}" >/dev/null 2>&1
