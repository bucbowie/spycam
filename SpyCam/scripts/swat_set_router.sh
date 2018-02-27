#!/bin/bash
# name: swat_set_router.sh
# desc:  Get IP and compares it definition in swat.config
#        If they differ, then update /etc/wpa_supplicant/wpa_supplicant.conf with 
#        IP defined in swat.config
# usage: ./swat_set_router.sh 
#
# TO-DO
# 1. create program to reconcile ETHERNET_DEVICE to MY_ROUTER_PW - pass DEVICE, return IP.
# 2. add sed to scan for router_line_item in for loop and update the next line (sed n)
#
#------------------------------------------------------------#
 function test_router_settings() {
#------------------------------------------------------------#
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."
 [[ -f /boot/swat.config ]] && { . /boot/swat.config; }
 if [[ (( -z "$MY_ROUTER_NAME}" ) || ( "${MY_ROUTER_NAME}" == "" ))  && (( -z "${MY_ROUTER_PW}" ) ||( "${MY_ROUTER_PW}" == "" )) ]];then
    {
      echo "##############################################"
      echo "# ${MY_SCRIPT} did not read valid values from "
      echo "# ${MY_SCRIPT_DIR}/swat.config.               "
      echo "# The items of interest are:                  "
      echo "# MY_ROUTER_NAME=${MY_ROUTER_NAME}      "
      echo "# MY_ROUTER_PW=${MY_ROUTER_PW}  "
      echo "# --> Set these values in swat.config and retry."
      echo "#---------------------------------------------"
      exit -1
    }
 fi
 }
MY_SCRIPT=swat_set_router.sh
 test_router_settings
 MY_SCRIPT_DIR=/home/swat/scripts
 MY_DATE=`date "+%Y%m%d_%H%M%S"`
 for router_line_item in MY_ROUTER_NAME MY_ROUTER_PW
   do
     ${MY_SCRIPT_DIR}/swat_get_router.sh ${router_line_item}|while read CURR_VALUE IN_VALUE
       do
         if [[ "${CURR_VALUE}" != "${IN_VALUE}" ]];then
           {
	      if [[ ( ! -z "{CURR_VALUE}" ) && ( ! -z "${IN_VALUE}" ) ]]; then
	        {
		  [[ -f /etc/wpa_supplicant/wpa_supplicant.conf.bak ]] && { mv /etc/wpa_supplicant/wpa_supplicant.conf.bak /etc/wpa_supplicant/wpa_supplicant.conf.bak."${MY_DATE}" ; }
                  sed -i.bak  '/'${CURR_VALUE}'/s/'${CURR_VALUE}'/'${IN_VALUE}'/'  /etc/wpa_supplicant/wpa_supplicant.conf
		  echo "RC=$?"
	        }
	     fi
           }
         fi
       done
   done
 echo "############################################"
 echo "# Results from ${MY_SCRIPT}"
 echo "############################################"
 cat /etc/wpa_supplicant/wpa_supplicant.conf|grep -v ^#|egrep "ssid|psk"
