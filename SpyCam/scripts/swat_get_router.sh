#!/bin/bash
# name: swat_get_router.sh
# desc: Pass it a device in swat.config and it returns the 
#       IP and compares it definition in swat.config
# usage: ./swat_get_router.sh line-item-in-swat.config
#
MY_SCRIPT_NAME=swat_get_router.sh
MY_SCRIPT_DIR=/home/swat/scripts
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 [[ -f "${MY_SCRIPT_DIR}/swat.config" ]] && source "${MY_SCRIPT_DIR}/swat.config"
 
 [[ $(($#)) -eq 0 ]] && { echo "Aborting with 0 arguments"; exit 1 ; } 

 IN_ARGUMENT=$1
 IN_VALUE=$(eval echo "\$${1}")
 #DEBUG echo "IN_ARGUMENT=${IN_ARGUMENT} IN_VALUE=${IN_VALUE}"
 if [[ ! -z "${IN_VALUE}" ]];then
   {
     case "${IN_ARGUMENT}" in
       MY_ROUTER_NAME)  CURR_VALUE=`cat /etc/wpa_supplicant/wpa_supplicant.conf|grep "ssid="|cut -d'"' -f2`
       ;;
       MY_ROUTER_PW)  CURR_VALUE=`cat /etc/wpa_supplicant/wpa_supplicant.conf|grep "psk="|cut -d'"' -f2`
       ;;
       *);;
     esac       
     #DEBUG echo "CURR_VALUE=${CURR_VALUE} IN_VALUE=${IN_VALUE}"
     if [[ "${CURR_VALUE}" != "${IN_VALUE}" ]];then
       {
         echo "${CURR_VALUE} ${IN_VALUE}"
       }
     fi
   }
 fi 

