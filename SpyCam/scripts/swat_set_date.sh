#!/bin/bash
# name: swat_set_date.sh
# desc: Returns formatted date to use in filename.
# usage: ./swat_set_date.sh
#
MY_SCRIPT=swat_set_date.sh
MY_SCRIPT_DIR=/home/swat/scripts
 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 [[ -f "${MY_SCRIPT_DIR}/swat.config" ]] && source "${MY_SCRIPT_DIR}/swat.config"

 if [[ ! -x ${MY_SCRIPT_DIR}/swat_get_date.sh ]]; then
   {
     in_object="${MY_SCRIPT}"
     in_rc=8
     in_msg="${MY_SCRIPT} unable to execute/access ${MY_SCRIPT_DIR}/swat_get_date.sh"
     common_error_report "${in_object}" ${in_rc} "${in_msg}"
   }
 fi
 
 ${MY_SCRIPT_DIR}/swat_get_date.sh|while read MY_CURR_DATE #MY_CURR_FOLDER
   do
     if [[ -z "${MY_CURR_DATE}" ]]; then
        {
	  in_object="${MY_SCRIPT}"
	  in_rc=8
	  in_msg="Expecting current date from swat_get_date.sh; MY_CURR_DATE=${MY_CURR_DATE}"
	  common_error_report "${in_object}"  ${in_rc}  "${in_msg}"
	  exit -1 
	}
     fi

     #echo -e "${MY_CURR_DATE}\c" 
  
     cd "${CAMERA_FOLDER_VIDEOS}"
     myCNT=0
     if [[ -f "${MY_CURR_DATE}.tar" ]]; then
       { 
	 myCNT=`ls -lart ${MY_CURR_DATE}.tar|wc -l` 
       }
     else
       { 
	 tar -cf ${MY_CURR_DATE}.tar -T /dev/null
	 myCNT=1
       }
     fi
     [[ $((myCNT)) -gt 0 ]] && echo "${MY_CURR_DATE}.tar"
   done
 exit 0

