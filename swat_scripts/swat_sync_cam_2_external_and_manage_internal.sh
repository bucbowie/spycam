#!/usr/bin/bash
# name: swat_sync_cam_2_external_and_manage_internal.sh
# desc: Copy local videos to remote storage if present.
#       Delete videos older than 3 days.
# usage: ./swat_sync_cam_2_external_and_manage_internal.sh
#
EXTERNAL_MOUNT=/media/cam
INTERNAL_MEDIA=/var/www/cam/media
 if [[  -d "${EXTERNAL_MOUNT}" ]];then
   {
      MY_MOUNT_SIZE=`df -k "${EXTERNAL_MOUNT}"|tail -1|grep [0-9]|awk '{print $4}'`
      if [[ ${MY_MOUNT_SIZE} -le 1024 ]];then
        {
          echo "${EXTERNAL_MOUNT} size of ${MY_MOUNT_SIZE} means no drive is mounted. Aborting with no action taken."
        }
      else
	{
          rsync -artv "${INTERNAL_MEDIA}" "${EXTERNAL_MOUNT}"/
	}
      fi
   }
 fi
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
 /usr/bin/find /var/www/cam/media -type d -mtime +3 -exec rm -rf {} \;
 /usr/bin/find /var/www/cam/media -name '*.mp4' -type f -mtime +3 -exec rm -f {} \;

