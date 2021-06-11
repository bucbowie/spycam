#!/usr/bin/bash
# name: swat_get_ip.sh
# desc: Pass it a device in swat.config and it returns the 
#       IP and compares it definition in swat.config
# usage: ./swat_get_ip.sh line-item-in-swat.config
#
MY_SCRIPT=swat_get_ip.sh
MY_SCRIPT_DIR=/home/swat/swat_scripts
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 [[ -e "${MY_SCRIPT_DIR}/swat.config" ]] && source "${MY_SCRIPT_DIR}/swat.config"
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
 
 [[ $(($#)) -eq 0 ]] && { echo "Aborting with 0 arguments"; exit 1 ; } 

 CONFIG_ARGUMENT=$1
 CONFIG_VALUE=$(eval echo "\$${1}")
 #DEBUG echo "CONFIG_ARGUMENT=${CONFIG_ARGUMENT} CONFIG_VALUE=${CONFIG_VALUE}"
 if [[ ! -z "${CONFIG_VALUE}" ]];then
   {
     case "${CONFIG_ARGUMENT}" in
       MY_SERVER_WIFI_IP)  CURR_VALUE=`ip -h -f inet route|grep "${WIFI_DEVICE}"|grep via|awk '{print $7}'`
       ;;
       MY_SERVER_STATIC_IP) CURR_VALUE=`ip -h -f inet route|grep "${ETHERNET_DEVICE}"|grep via|awk '{print $7}'`
       ;;
       *);;
     esac       
     [[ -z "${CURR_VALUE}" ]] && { export CURR_VALUE="\"\""; }
     #DEBUG echo "CURR_VALUE=${CURR_VALUE} CONFIG_VALUE=${CONFIG_VALUE}"
     if [[ "${CURR_VALUE}" != "${CONFIG_VALUE}" ]];then
       {
         echo "${CURR_VALUE} ${CONFIG_VALUE}"
       }
     fi
   }
 fi 

