#!/bin/bash
EXTERNAL_MOUNT=/media/cam
INTERNAL_MEDIA=/var/www/cam/media
 if [[ ! -d "${EXTERNAL_MOUNT}" ]];then
   {
     echo "${EXTERNAL_MOUNT} directory not found. Aborting with no action taken."
     exit -1
   }
 fi
 MY_MOUNT_SIZE=`df -k "${EXTERNAL_MOUNT}"|tail -1|grep [0-9]|awk '{print $4}'`
 if [[ ${MY_MOUNT_SIZE} -le 1024 ]];then
   {
     echo "${EXTERNAL_MOUNT} size of ${MY_MOUNT_SIZE} means no drive is mounted. Aborting with no action taken."
     exit -1
   }
 fi
 rsync -artv "${INTERNAL_MEDIA}" "${EXTERNAL_MOUNT}"/
 echo "${INTERNAL_MEDIA}" "${EXTERNAL_MOUNT}"/

 MY_MOUNT_SIZE=`df -k /var/www/cam/media|tail -1|awk '{print $4}'`
 echo "MY_MOUNT_SIZE=${MY_MOUNT_SIZE}"

 if [[ ${MY_MOUNT_SIZE} -lt 500000 ]];then
   {
     cd /var/www/cam/media
     MY_GUY_TO_DIE=`ls -lat *.tar|tail -1|awk '{print $9}'`
     echo "MY_GUY_TO_DIE=${MY_GUY_TO_DIE}"
     rm -f "${MY_GUY_TO_DIE}"
   }
 fi

