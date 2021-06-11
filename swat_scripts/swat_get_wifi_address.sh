#!/usr/bin/bash
# name: swat_get_wifi_address.sh
# desc: Assign a new wireless IP
# usage: ./swat_get_address.sh
#
 MY_IP_VLAN=""
 MY_IP_NODE=""
 MY_NEW_IP=""
 MY_SCRIPT="swat_get_wifi_address.sh"
 #-------------------------------------#
 function process_new_ip() {
 #-------------------------------------#
 MY_NEW_IP=$1
 [[ -z "${MY_NEW_IP}" ]] && { return 8; }
 echo "${MY_NEW_IP}"
 }
 ######################################
 # MAIN LOGIC STARTS HERE             #"$
 ######################################
 [[ -z "${SCRIPT_DIR}" ]] && { export SCRIPT_DIR="."; }
 [[ -f "${SCRIPT_DIR}"/swat.config ]] && { . "${SCRIPT_DIR}"/swat.config; }
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
 [[ -z "${MY_ROUTER_IP}" ]] && { exit 0; }

 export MY_IP_VLAN=`echo ${MY_ROUTER_IP}|cut -d"." -f1-3`
 [[ -z "${MY_IP_VLAN}" ]] && { exit 0; }
#-------------------------------------#
# Get IP list of what is currently connected to Wireless router
#-------------------------------------#
 declare MY_ARRAY=(`arp-scan --interface=wlan0 "${MY_ROUTER_IP}"/24 2>/dev/null|grep :|grep -wv "${MY_ROUTER_IP}"|grep ^[0-9]|awk '{print $1}'|cut -d"." -f4|sort`)
 [[ -z "${MY_ARRAY[*]}" ]] && { exit 0; }

 for i in `echo "${MY_ARRAY[*]}"`
   do
     let MY_IP_NODE=$(($i+1))
     ping -c +1 "${MY_IP_VLAN}"."${MY_IP_NODE}" > /dev/null 2>&1
     myRC=$?
     if [[ ${myRC} -eq 1 ]];then
       {
	 process_new_ip "${MY_IP_VLAN}"."${MY_IP_NODE}"
	 break;
       }
     fi
  done
