#!/bin/bash
# name: swat_set_ip.sh
# desc:  Get IP and compares it definition in swat.config
#        If they differ, then update /etc/dhcpcd.conf with 
#        IP defined in swat.config
# usage: ./swat_set_ip.sh 
#
# TO-DO
# 1. create program to reconcile ETHERNET_DEVICE to MY_SERVER_STATIC_IP - pass DEVICE, return IP.
# 2. add sed to scan for interface in for loop and update the next line (sed n)
#
#------------------------------------------------------------#
 function test_ip_address() {
#------------------------------------------------------------#
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."
 [[ -f /boot/swat.config ]] && { . /boot/swat.config; }
 if [[ (( -z "$MY_SERVER_WIFI_IP}" ) || ( "${MY_SERVER_WIFI_IP}" == "" ))  && (( -z "${MY_SERVER_STATIC_IP}" ) ||( "${MY_SERVER_STATIC_IP}" == "" )) ]];then
    {
      echo "##############################################"
      echo "# ${MY_SCRIPT} did not read valid values from "
      echo "# ${MY_SCRIPT_DIR}/swat.config.               "
      echo "# The items of interest are:                  "
      echo "# MY_SERVER_WIFI_IP=${MY_SERVER_WIFI_IP}      "
      echo "# MY_SERVER_STATIC_IP=${MY_SERVER_STATIC_IP}  "
      echo "# --> Set these values in swat.config and retry."
      echo "#---------------------------------------------"
      exit -1
    }
 fi
 }
MY_SCRIPT=swat_set_ip.sh
 test_ip_address
 MY_SCRIPT_DIR=/home/swat/scripts
 MY_DATE=`date "+%Y%m%d_%H%M%S"`
 for interface in MY_SERVER_WIFI_IP MY_SERVER_STATIC_IP
   do
     ${MY_SCRIPT_DIR}/swat_get_ip.sh ${interface}|while read CURR_VALUE IN_VALUE
       do
         if [[ "${CURR_VALUE}" != "${IN_VALUE}" ]];then
           {
	      if [[ ( ! -z "{CURR_VALUE}" ) && ( ! -z "${IN_VALUE}" ) ]]; then
	        {
		  [[ -f /etc/dhcpcd.conf.bak ]] && { mv /etc/dhcpcd.conf.bak /etc/dhcpcd.conf.bak."${MY_DATE}" ; }
                  sed -i.bak '/'${interface}'/n;{s/'${CURR_VALUE}'/'${IN_VALUE}'/}' /etc/dhcpcd.conf
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
 cat /etc/dhcpcd.conf|grep -v ^#|egrep -b1 "ip_address"|grep -v router
