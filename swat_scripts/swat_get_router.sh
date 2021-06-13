#!/usr/bin/bash
# name: swat_get_router.sh
# desc: Pass it a device in swat.config and it returns the 
#       IP and compares it definition in swat.config
# usage: ./swat_get_router.sh line-item-in-swat.config
#
MY_SCRIPT_NAME=swat_get_router.sh
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
 
 [[ $(($#)) -eq 0 ]] && { echo "Aborting with 0 arguments"; exit 1 ; } 

 IN_ARGUMENT=$1
 IN_VALUE=$(eval echo "\$${1}")
 #DEBUGecho "IN_ARGUMENT=${IN_ARGUMENT} IN_VALUE=${IN_VALUE}"
 if [[ ! -z "${IN_VALUE}" ]];then
   {
     case "${IN_ARGUMENT}" in
       MY_ROUTER_NAME)  CURR_VALUE=`cat /etc/wpa_supplicant/wpa_supplicant.conf|grep "ssid="|cut -d'"' -f2`
       ;;
       MY_ROUTER_PW)  CURR_VALUE=`cat /etc/wpa_supplicant/wpa_supplicant.conf|grep "psk="|cut -d'"' -f2`
       ;;
       *);;
     esac       
     #DEBUG echo "swat_get_router.sh:  CURR_VALUE=${CURR_VALUE} IN_VALUE=${IN_VALUE}"
     [[ -z "${CURR_VALUE}" ]] && { export CURR_VALUE="\!"; }

     if [[ "${CURR_VALUE}" != "${IN_VALUE}" ]];then
       {
         echo "${CURR_VALUE}  ${IN_VALUE}"
       }
     fi
   }
 fi 

