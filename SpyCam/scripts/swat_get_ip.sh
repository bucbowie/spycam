#!/bin/bash
# name: swat_get_ip.sh
# desc: Pass it a device in swat.config and it returns the 
#       IP and compares it definition in swat.config
# usage: ./swat_get_ip.sh line-item-in-swat.config
#
MY_SCRIPT_NAME=swat_get_ip.sh
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
       MY_SERVER_WIFI_IP)  CURR_VALUE=`ip -h -f inet route|grep "${WIFI_DEVICE}"|grep via|awk '{print $7}'`
       ;;
       MY_SERVER_STATIC_IP) CURR_VALUE=`ip -h -f inet route|grep "${ETHERNET_DEVICE}"|grep via|awk '{print $7}'`
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

