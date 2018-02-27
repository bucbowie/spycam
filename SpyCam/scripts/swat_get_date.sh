#!/bin/bash
# name: swat_get_date.sh
# desc: Returns formatted date to use in filename.
# usage: ./swat_get_date.sh
#
MY_SCRIPT=swat_get_date.sh
MY_SCRIPT_DIR=/home/swat/scripts
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 [[ -f "${MY_SCRIPT_DIR}/swat.config" ]] && source "${MY_SCRIPT_DIR}/swat.config"
 
 MY_CURR_DATE=`date +%Y%m%d`
 echo -e "${MY_CURR_DATE}" 
  
# cd "${CAMERA_FOLDER_VIDEOS}"
# myCNT=0
# [[ -e "${MY_CURR_DATE}.tar" ]] && myCNT=`ls -lart ${MY_CURR_DATE}.tar|wc -l`
# [[ $((myCNT)) -gt 0 ]] && echo " ${MY_CURR_DATE}.tar"

 exit 0

