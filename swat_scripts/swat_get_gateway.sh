#!/usr/bin/bash
# name: swat_get_gateway.sh
# desc: Extract router IP (Gateway). Returns Gateway IP. 
# usage: ./swat_get_gateway.sh 
#
MY_SCRIPT=swat_get_gateway.sh
MY_SCRIPT_DIR=/home/swat/swat_scripts
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 [[ -f "${MY_SCRIPT_DIR}/swat.config" ]] && source "${MY_SCRIPT_DIR}/swat.config"
 myRC=$?
 if [[ ${myRC} -ne 0 ]]; then
   {
     echo "#######################################"
     echo "# ${MY_SCRIPT} unable to load ${SCRIPT_DIR}/swat.config" 
     echo "# Aborting with no action taken.      "
     echo "# Your wireless IP address will not be"
     echo "# changed by this script.             "
     echo "# Returning to install.sh to continue."
     echo "#------------------------------------#"
     exit 4
   }
 fi
 
 export MY_GATEWAY_IP=`ip -h -f inet route|grep "${WIFI_DEVICE}"|grep via|awk '{print $3}'`
 [[ -z "${MY_GATEWAY_IP}" ]] && { export MY_GATEWAY_IP=`ip -h -f inet route|grep "${ETHERNET_DEVICE}"|grep via|awk '{print $3}'`; } 
 if [[ -z "${MY_GATEWAY_IP}" ]];then
   {
     echo "#######################################"
     echo "# ${MY_SCRIPT} unable to find GATEWAY, " 
     echo "# to determine router IP.              "
     echo "# Aborting with no action taken.       "
     echo "# - - - - - - - - - - - - - - - - - - -"
     echo "# Your router IP address will not be   "
     echo "# inserted into /boot/swat.config.     "
     echo "# Suggest you do this manually. The    "
     echo "# field to update is MY_ROUTER_IP.     " 
     echo "#-------------------------------------#"
     exit 4
   }
 fi
 echo "${MY_GATEWAY_IP}"
