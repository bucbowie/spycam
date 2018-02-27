#!/bin/bash
# name: swat_set_email.sh
# desc:  Get EMAIL and compares it definition in swat.config
#        If they differ, then update /etc/ssmtp/ssmtp.conf with 
#        email defined in swat.config
# usage: ./swat_set_email.sh 
#
# TO-DO
#
#------------------------------------------------------------#
 function test_email_settings() {
#------------------------------------------------------------#
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."
 [[ -f /boot/swat.config ]] && { . /boot/swat.config; }
 CNT_EMAIL_ADDRESS=`env|grep MY_EMAIL_ADDRESS|wc -l`
 CNT_EMAIL_PW=`env|grep MY_EMAIL_PW|wc -l`
 if [[ (( -z "${MY_EMAIL_ADDRESS}"  )  && ( ${CNT_EMAIL_ADDRESS} -eq 0 )) || (( -z "${MY_EMAIL_PW}" ) && ( ${CNT_EMAIL_PW} -eq 0 ))  ]];then
    {
      echo "##############################################"
      echo "# ${MY_SCRIPT} did not read valid values from "
      echo "# ${MY_SCRIPT_DIR}/swat.config.               "
      echo "# The items of interest are:                  "
      echo "# MY_EMAIL_ADDRESS=${MY_EMAIL_ADDRESS}        "
      echo "# MY_EMAIL_PW=${MY_EMAIL_PW}                  "
      echo "# --> Set these values in swat.config and retry."
      echo "#---------------------------------------------"
      exit -1
    }
 fi
 }
 #####################################################
 # MAIN LOGIC STARTS HERE
 #####################################################

 MY_SCRIPT=swat_set_email.sh
 test_email_settings
 MY_SCRIPT_DIR=/home/swat/scripts
 MY_DATE=`date "+%Y%m%d_%H%M%S"`
 for email_line_item in MY_EMAIL_ADDRESS MY_EMAIL_PW
   do
     ${MY_SCRIPT_DIR}/swat_get_email.sh ${email_line_item}|while read CURR_VALUE IN_VALUE
       do
         if [[ "${CURR_VALUE}" != "${IN_VALUE}" ]];then
           {
		  [[ -f /etc/ssmtp/ssmtp.conf.bak ]] && { mv /etc/ssmtp/ssmtp.conf.bak /etc/ssmtp/ssmtp.conf.bak."${MY_DATE}" ; }
                  sed -i.bak  '/'${CURR_VALUE}'/s/'${CURR_VALUE}'/'${IN_VALUE}'/'  /etc/ssmtp/ssmtp.conf
		  echo "RC=$?"
           }
         fi
       done
   done
 echo "############################################"
 echo "# Results from ${MY_SCRIPT}"
 echo "############################################"
 cat /etc/ssmtp/ssmtp.conf|grep -v ^#|egrep "Auth"
