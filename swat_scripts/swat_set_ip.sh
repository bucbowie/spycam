#!/usr/bin/bash
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
      echo "# Leaving script with no action taken.        "
      echo "#---------------------------------------------"
      exit 0
    }
 fi
 }
############################################################
# MAIN LOGIC STARTS HERE
############################################################
MY_SCRIPT=swat_set_ip.sh
 test_ip_address
 MY_SCRIPT_DIR=/home/swat/swat_scripts
 MY_DATE=`date "+%Y%m%d_%H%M%S"`
 for interface in MY_SERVER_WIFI_IP MY_SERVER_STATIC_IP
   do
     ${MY_SCRIPT_DIR}/swat_get_ip.sh ${interface}|while read CURR_VALUE IN_VALUE
       do
         if [[ "${CURR_VALUE}" != "${IN_VALUE}" ]];then
           {
	     if [[ ( -z "${IN_VALUE}" ) || ( "${IN_VALUE}" == "\"\"" ) ]];then
	       {
                  echo "############################################"
		  echo "# ${MY_SCRIPT} read empty STATIC IP in swat.config."
		  echo "# Assuming and defaulting to DHCP, where the"
		  echo "# Raspberry Pi I.P. is dynamically set.     "
		  echo "# Currently the I.P. is ${CURR_VALUE}.      " 
		  echo "# Leaving script with no action taken.      "
                  echo "############################################"
	          exit 0
	       }
	     fi
	     [[ -f /etc/dhcpcd.conf.bak ]] && { mv /etc/dhcpcd.conf.bak /etc/dhcpcd.conf.bak."${MY_DATE}" ; }
	     myCNT=`cat /etc/dhcpcd.conf|grep -v ^\#|grep wlan0|wc -l`
	     if [[ ${myCNT} -eq  0 ]]; then
	       {
	         echo " interface ${WIFI_DEVICE}" |tee  -a /etc/dhcpcd.conf
	         echo " static ip_address=${MY_SERVER_WIFI_IP}/24"|tee -a  /etc/dhcpcd.conf
	         echo " static routers=${MY_ROUTER_IP}"|tee -a  /etc/dhcpcd.conf
	         echo " static domain_name_servers=${MY_ROUTER_IP}"|tee -a  /etc/dhcpcd.conf
	         echo " static domain_name_servers=8.8.8.8"|tee -a /etc/dhcpcd.conf
	         echo " static domain_name_servers=8.8.4.4"|tee -a /etc/dhcpcd.conf
	       }
	     else
	       {
	         sed -i.bak  '/'${WIFI_DEVICE}'/n; s/static ip_address=.*$/static ip_address='${MY_SERVER_WIFI_IP}'/' /etc/dhcpcd.conf
	       }
	    fi

       }
	     fi
       done
   done
 echo "############################################"
 echo "# Results from ${MY_SCRIPT}"
 echo "############################################"
 cat /etc/dhcpcd.conf|grep -v ^\#|egrep -b1 "ip_address"|grep -v router
