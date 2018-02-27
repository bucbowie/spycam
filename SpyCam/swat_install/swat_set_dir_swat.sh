#!/bin/bash
# name: swat_set_dir_swat.sh
# desc: Creates script directory for user swat.
# usage: ./swat_set_dir_swat.sh
# 
 export MY_SCRIPT="swat_set_dir_swat.sh"
 [[ -z "${SCRIPT_DIR}" ]] && { export SCRIPT_DIR=".";}
 export IN_DIR="scripts"
 export IN_USER=`sudo ./swat_get_user_swat.sh`
 export IN_USER_HOME=`grep ${IN_USER} /etc/passwd|cut -d":" -f6`
 if [[ -d "${IN_USER_HOME}" ]];then
   {
     :
   }
 else
   {
     echo "############################################"
     echo "# ${MY_SCRIPT} unable to access HOME dir of $IN_USER_HOME}"
     echo "#              for user ${IN_USER}          "
     echo "# Aborting script with no action taken.     "
     echo "############################################"
     exit -1
   }
 fi
 if [[ -d "${IN_USER_HOME}/${IN_DIR}" ]];then
   {
     echo "${IN_USER_HOME}/${IN_DIR}"
     exit 0
   }
 fi
 sudo mkdir -p "${IN_USER_HOME}/${IN_DIR}"
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "############################################"
     echo "# ${MY_SCRIPT} unable to create dir ${IN_DIR}."
     echo "#              for user ${IN_USER}          "
     echo "# Aborting script with no action taken.     "
     echo "############################################"
   }
 fi
 echo "${IN_USER_HOME}/${IN_DIR}"
 exit 0
     

