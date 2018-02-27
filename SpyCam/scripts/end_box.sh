#!/bin/bash
# name: end_box.sh
# desc:  Takes current captured video (mp4) 
#        and emails the first in the list of mp4. 
#        Tars up the rest of the videos in tar 
#        folder. Keeps current directory clean
#        and organizes videos by date/folder.
# usage: ./end_box.sh 
#
MY_SCRIPT=end_box.sh
MY_SCRIPT_DIR=/home/swat/scripts
MY_EMAIL_COUNTER=0

 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 set -avx

 [[ -f "${MY_SCRIPT_DIR}/swat.config" ]] && source "${MY_SCRIPT_DIR}/swat.config"

 if [[ -x "${MY_SCRIPT_DIR}"/swat_set_date.sh ]]; then
   {
     MY_TAR_FILE=`${MY_SCRIPT_DIR}/swat_set_date.sh`
   }
 else
   {
	   in_object="${MY_SCRIPT}"
	   in_rc=9
	   in_msg="Unable to access ${MY_SCRIPT_DIR}/swat_set_date.sh"
	   common_error_report "${in_object}" ${in_rc} "${in_msg}"
	   exit -1
  }
fi

 if [[ -d "${CAMERA_FOLDER_VIDEOS}" ]];then
   {
     cd "${CAMERA_FOLDER_VIDEOS}" 
   }
 else
   {
     in_object="${MY_SCRIPT}"
     in_rc=10
     in_msg="Unable to access ${CAMERA_FOLDER_VIDEOS}"
     common_error_report "${in_object}" ${in_rc} "${in_msg}"
     exit -1
   }
 fi

 [[ ! `ls -lart ./mp4.b4|awk '{print $NF}'`  ]] && touch ./mp4.b4

 [[ `ls -la *.mp4|awk '{print $NF}'` ]] && ls -lart *.mp4|awk '{print $NF}' > mp4.curr || echo "" > mp4.curr

export list=`diff -u -b -B ./mp4.b4 ./mp4.curr|grep -E  "^\+"|awk '{print $NF}'|rev |cut -d"-" -f2|rev|sed 's/\+//g'`

my_clean_list=`echo "${list}"|grep mp4`

echo "my_clean_list=${my_clean_list}"

if [[ ( -z "${my_clean_list}" ) ]]; then
   {
	if [[ ( ! -z `cat ./mp4.b4` )  && (  -z `cat ./mp4.curr` ) ]];then
	   {
             mv ./mp4.b4 ./mp4.curr
	     touch ./mp4.b4
	   }
	fi
   }
 else 
   {
     echo "${my_clean_list}" | while read list 
       do
	 if [[ ( ${MY_EMAIL_COUNTER} -eq 0 ) && ( ! -z "${MY_EMAIL_ADDRESS}" ) ]];then
           {
	     echo "sending ${list} via email " > /tmp/end_box.log 2>&1
	     mpack -s "${MY_CAMERA_NAME} alert" /var/www/cam/media/"${list}" "${MY_EMAIL_ADDRESS}" 
	     let MY_EMAIL_COUNTER+=1
	   }
	 fi
 	 echo "sending ${list} to ${MY_TAR_FILE}" >> /tmp/end_box.log 2>&1
	 tar -rf "${MY_TAR_FILE}" "${list}"
	 rm -f "${list}"
	 rm -f *.jpg
      done 
   }
 fi
 rm -f ./mp4.curr ./mp4.b4
