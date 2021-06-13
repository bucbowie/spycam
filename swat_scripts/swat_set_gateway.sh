#!/usr/bin/bash
# name: swat_set_gateway.sh
# desc: Assign STATIC IP to Router 
# usage: ./swat_set_gateway.sh
#
set -a
 export MY_SCRIPT="swat_set_gateway.sh"
 export SCRIPT_DIR=/home/swat/swat_scripts
 [[ -f "${SCRIPT_DIR}"/swat.config ]] && { . "${SCRIPT_DIR}"/swat.config; }
 myRC=$?
 if [[ ${myRC} -ne 0 ]]; then
   {
     echo "#######################################"
     echo "# ${MY_SCRIPT} unable to load ${SCRIPT_DIR}/swat.config" 
     echo "# Aborting with no action taken.      "
     echo "# - - - - - - - - - - - - - - - - - - #"
     echo "# Your wireless IP address will not be"
     echo "# changed by this script.             "
     echo "# Please review ${SCRIPT_DIR}/swat.config"
     echo "# Does it exist and is it accessible? "
     echo "# There are arguments needed by this script."
     echo "# Review /boot/swat.config for argument: MY_ROUTER_IP"
     echo "# and make adjustments accordingly to    "
     echo "# match your desire wireless IP.         "
     echo "# - - - - - - - - - - - - - - - - - - #"
     echo "# Returning to install.sh to continue."
     echo "#------------------------------------#"
     exit 4
   }
 fi
 if [[ ! -z "${MY_ROUTER_IP}" ]];then
   {
     echo "#######################################"
     echo "# I N F O R M A T I O N A L            "
     echo "#--------------------------------------"
     echo "# ${MY_SCRIPT} found swat.config       "
     echo "# contained MY_ROUTER_IP=${MY_ROUTER_IP}"
     echo "# --> using existing ${MY_ROUTER_IP}   "
     echo "#     for the router IP (Gateway).     "
     echo "# No modification to swat.config.      "
     echo "# Processing continues...              "
     echo "#--------------------------------------"
  }
 else
   {
     export MY_NEW_GATEWAY_ADDRESS=`${SCRIPT_DIR}/swat_get_gateway.sh`
     myRC=$?
     if [[ ( ${myRC} -ne 0 ) || (  -z "${MY_NEW_GATEWAY_ADDRESS}" )  ]];then
       {
	     echo "#######################################"
             echo "# E R R O R                            "
             echo "#-------------------------------------#"
	     echo "# ${MY_SCRIPT} unable to set MY_NEW_GATEWAY_ADDRESS using ${MY_NEW_GATEWAY_ADDRESS}" 
	     echo "# Aborting with no action taken.       "
	     echo "# - - - - - - - - - - - - - - - - - - "
	     echo "# Either MY_NEW_GATEWAY_ADDRESS failed to be set,"
	     echo "# or                                   "
	     echo "# ${SCRIPT_DIR}/swat_get_gateway.sh"
	     echo "# had issues or was not found in ${SCRIPT_DIR}"
	     echo "#-------------------------------------#"
	     exit 4
       }
     fi
     sudo sed -i.bak '/MY_ROUTER_IP/s/MY_ROUTER_IP=\"\"/MY_ROUTER_IP=\"'"${MY_NEW_GATEWAY_ADDRESS}"'\"/' /boot/swat.config
     myRC=$?
     if [[ ${myRC} -ne 0 ]]; then
	   {
	     echo "#######################################"
             echo "# E R R O R                            "
             echo "#-------------------------------------#"
	     echo "# ${MY_SCRIPT} found MY_NEW_GATEWAY_ADDRESS=${MY_NEW_GATEWAY_ADDRESS}" 
	     echo "# but unable to modify /boot/swat.config."
	     echo "# Aborting ${MY_SCRIPT} during execution."
	     echo "# - - - - - - - - - - - - - - - - - - -"
	     echo "# Review /boot/swat.config for argument: MY_ROUTER_IP"
	     echo "# and make adjustments accordingly to    "
	     echo "# match your desire wireless IP.         "
	     echo "#---------------------------------------#"
	     exit 0
	   }
    else
       {
	     echo "#######################################"
             echo "# I N F O R M A T I O N A L            "
             echo "#--------------------------------------"
	     echo "# ${MY_SCRIPT} setting swat.config:    "
	     echo "# MY_ROUTER_IP to ${MY_NEW_GATEWAY_ADDRESS}." 
	     echo "#--------------------------------------"
      }
    fi
   }
fi

