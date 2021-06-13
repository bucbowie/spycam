#!/usr/bin/bash
# name: swat_scan_for_cell_phone.sh
# desc: Search wireless router for presence of cell phone.
# usage: ./swat_scan_for_cell_phone.sh
#-----------------------------------------------------------#
# Variables and Files to hold information
#-----------------------------------------------------------#
export mySCRIPT_DIR=/home/swat/swat_scripts
cd /home/swat/swat_scripts
set -avx
mySCRIPT="swat_scan_for_cell_phone.sh"
CNT_RUNNING_TALLY=/tmp/try.cnt
 [[ ! -e "${CNT_RUNNING_TALLY}" ]] && echo 0 > "${CNT_RUNNING_TALLY}"
myPREV_STATE=/tmp/${mySCRIPT}.prev_state
myCURR_STATE=/tmp/${mySCRIPT}.curr_state
MSG_ABSENT="ABSENT"
MSG_PRESENT="PRESENT"
if [[ -z `which arp-scan` ]];then
   {
     echo "************************************"
     echo "* ${mySCRIPT}  requires arp-scan to be installed".
     echo "* Suggestion: apt-get install arp-scan, then retry script"
     echo "* Aborting script with no action taken".
     exit 254
  }
 fi
 if [[ ! -d $HOME/logs ]];then
   {
     mkdir $HOME/logs
   }
 fi
#-----------------------------------------------------------#
# MAIN LOGIC STARTS HERE                                    #
#-----------------------------------------------------------#
 [[ ! -e "${myPREV_STATE}" ]] && touch "${myPREV_STATE}"
 [[ ! -e "${myCURR_STATE}" ]] && touch "${myCURR_STATE}"

 if [[ -f ./swat.config ]]; then
   {
	 . ./swat.config
   }
 elif [[ -f /boot/swat.config ]];then 
   {
     . /boot/swat.config
   }
 else
   {
      echo "##########################################"
      echo "# Error: swat.config not found.           "
      echo "#        This needs to be found and moved "
      echo "#        to either this current directory "
      echo "#        of `echo ${PWD}`"
      echo "#        or /boot/swat.config.            "
      echo "# Aborting swat_scripts with no action taken.  "
      exit -1
   }
 fi

     
 if [[ ( -z "${CELL_STATIC_IP}" ) && ( -z "${CELL_WIFI_MAC_ADDRESS}" ) ]];then
   {
      echo "##########################################"
      echo "# Error: swat_scan_for_cell_phone.sh      "
      echo "#        does not know of your cell phone."
      echo "# Suggestion: edit and modify the script  "
      echo "# swat.config with your hardware information,"
      echo "# then try running this again.            "
      echo "# CELL_STATIC_IP = ${CELL_STATIC_IP}      "
      echo "# CELL_WIFI_MAC_ADDRESS = ${CELL_WIFI_MAC_ADDRESS}"
      echo "# MY_ROUTER_IP = ${MY_ROUTER_IP}          "
      echo "# Aborting with no action taken.          "
      exit -1
   }
 fi
 #---------------------------------------------------#
 # Scan for Bluetooth before cell phone.             #
 # Scan for BLE before older Bluetooth.              #
 #---------------------------------------------------#
 COUNT_HIT_ON_CELL_OR_BT=`hcitool info "${CELL_BLUETOOTH_ADDRESS}"|grep -w Features|wc -l`
 if [[ $((COUNT_HIT_ON_CELL_OR_BT)) -eq  0 ]];then
   {
	 #-------------------------------------------------------#
	 # Avoid false positives if the router goes down or unavailable.
	 #-------------------------------------------------------#
	 SCAN_ROUTER=`/sbin/iwlist scan 2>/dev/null|grep ESSID|grep "${MY_ROUTER_NAME}"|cut -d":" -f2`
	 if [[ "${SCAN_ROUTER}" == \""${MY_ROUTER_NAME}"\" ]]; then
	   {
	      echo "Match on SCAN_ROUTER=${SCAN_ROUTER} MY_ROUTER_NAME=${MY_ROUTER_NAME}"
	      COUNT_HIT_ON_CELL_OR_BT=`arp-scan --interface=wlan0 "${MY_ROUTER_IP}/24" 2>/dev/null|grep "${CELL_STATIC_IP}"|wc -l`
	   }
	 else
	   {
	   #-----------------------------------------------------#
	   # Router not available. Do not trip the COUNT_HIT_ON_CELL_OR_BT=0.
	   #-----------------------------------------------------#
	     let COUNT_HIT_ON_CELL_OR_BT=1
	   }
	 fi
   }
 fi
 echo "COUNT_HIT_ON_CELL_OR_BT=${COUNT_HIT_ON_CELL_OR_BT}"
 if [[  $((COUNT_HIT_ON_CELL_OR_BT)) -eq 0  ]];then
   {
     if [[ ( `cat "${myCURR_STATE}"`  == "" ) || ( `cat "${myCURR_STATE}"` == "${MSG_PRESENT}" ) ]];then 
        {
	   echo "Setting myCURR_STATE to ${MSG_ABSENT}"
           echo "${MSG_ABSENT}" > "${myCURR_STATE}" 
	}
     fi
   }
 fi
	   
#     echo "COUNT_HIT_ON_CELL_OR_BT=${COUNT_HIT_ON_CELL_OR_BT}"
#     if [[  `cat ${CNT_RUNNING_TALLY}` -eq 5 ]]; then
#        {
#	  echo "CNT_RUNNING_TALLY=5"
#          if [[  "${myPREV_STATE}" != "${myCURR_STATE}"  ]];then
#	     {
#	       echo "myPREV_STATE=`cat ${myPREV_STATE}`"
#	       echo "myCURR_STATE=`cat ${myCURR_STATE}`"
#               echo "${MSG_ABSENT}" > "${myCURR_STATE}" 
#	     }
#	  fi
#	}
#      fi
#  }
 if [[ $((COUNT_HIT_ON_CELL_OR_BT)) -gt 0 ]];then
   {
     echo "${MSG_PRESENT}" > "${myCURR_STATE}" 
     echo 0 > "${CNT_RUNNING_TALLY}"
     myPID=`pidof raspimjpeg|awk '{print $1}'`
     if [[ ( ! -z "${myPID}" ) && ( $((myPID)) -gt 1 ) ]];then
       {
         ${mySCRIPT_DIR}/shutdown_services.sh > $HOME/logs/shutdown_services.log 2>&1 &
       }
     fi
   }
 else
   {
     :
     #rm -f "${myCURR_STATE}"
     #touch "${myCURR_STATE}"
   }
 fi
 [[ ( -z `cat ${CNT_RUNNING_TALLY}` ) || ( `cat ${CNT_RUNNING_TALLY}` -lt 0 ) ]] && echo 0 > "${CNT_RUNNING_TALLY}"
 [[ ( -z "${CAMERA_CNT_WIFI_ABSENT_MINUTES}" ) || ( $((CAMERA_CNT_WIFI_ABSENT_MINUTES)) -lt 0 ) ]] && set CAMERA_CNT_WIFI_ABSENT_MINUTES=0
 if [[ `cat ${CNT_RUNNING_TALLY}`  -lt ${CAMERA_CNT_WIFI_ABSENT_MINUTES} ]];then
   {
	   echo $((`cat  ${CNT_RUNNING_TALLY}`+1)) > "${CNT_RUNNING_TALLY}" 

   }
 else
   {
     if [[ ( `cat "${myCURR_STATE}"` == `cat "${myPREV_STATE}"` ) && ( `cat "${CNT_RUNNING_TALLY}"` -eq ${CAMERA_CNT_WIFI_ABSENT_MINUTES} )  ]];then
       {
	 case "`cat ${myCURR_STATE}`" in
	     ABSENT) myPID=`pidof raspimjpeg|awk '{print $1}'`

		     if [[ ( -z "${myPID}" ) || ( $((myPID)) -lt 1 ) ]];then
		       {
		         ${mySCRIPT_DIR}/startup_services.sh > $HOME/logs/startup_services.log 2>&1 &
		       }
		     fi
		     ;;
	    PRESENT) ${mySCRIPT_DIR}/shutdown_services.sh > $HOME/logs/shutdown_services.log 2>&1 & ;;
	          *) ;;
	  esac
 	  echo 0 > "${CNT_RUNNING_TALLY}"
          cat "${myCURR_STATE}" > "${myPREV_STATE}"
       }
     fi
   }
 fi 
 cat "${myCURR_STATE}" > "${myPREV_STATE}"
