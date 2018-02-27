#!/bin/bash
# name: swat_get_email.sh
# desc: Pass it a device in swat.config and it returns the 
#       email and compares it definition in swat.config
# usage: ./swat_get_email.sh line-item-in-swat.config
#
MY_SCRIPT_NAME=swat_get_email.sh
MY_SCRIPT_DIR=/home/swat/scripts
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 [[ -f /boot/swat.config ]] && source "${MY_SCRIPT_DIR}/swat.config"
 
 [[ $(($#)) -eq 0 ]] && { echo "Aborting with 0 arguments"; exit 1 ; } 

 IN_ARGUMENT=$1
 IN_VALUE=$(eval echo "\$${1}")
#DEBUG  echo "IN_ARGUMENT=${IN_ARGUMENT} IN_VALUE=${IN_VALUE}"
 if [[  -z "${IN_VALUE}" ]];then
   {
     IN_VALUE='""'
   }
 fi
 case "${IN_ARGUMENT}" in
    MY_EMAIL_ADDRESS)  CURR_VALUE=`cat /etc/ssmtp/ssmtp.conf|grep "AuthUser="|cut -d"=" -f2`
                       CURR_KEY="AuthUser="
       ;;
    MY_EMAIL_PW)  CURR_VALUE=`cat /etc/ssmtp/ssmtp.conf|grep "AuthPass="|cut -d'=' -f2`
                  CURR_KEY="AuthPass="
       ;;
    *);;
 esac       
#DEBUG  echo "CURR_VALUE=${CURR_VALUE} IN_VALUE=${IN_VALUE}"
#     if [[ "${CURR_VALUE}" != "${IN_VALUE}" ]];then
#       {
         echo "${CURR_KEY}${CURR_VALUE}" "${CURR_KEY}${IN_VALUE}"
#       }
#     fi

