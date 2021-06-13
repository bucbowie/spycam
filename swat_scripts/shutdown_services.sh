#!/usr/bin/bash
# name: shutdown_services.sh
# desc: Script to call on boot up from systemd.
# usage: ./shutdown_services.sh
#
MY_DATE=`date +%Y.%m.%d_%H.%M.%S`
MY_HOST=`uname -n`
###
### Start video feed
echo "md0" > /var/www/cam/FIFO
/opt/src/RPi_Cam_Web_Interface/stop.sh
###
###
echo "shutdown_services.sh completing on ${MYHOST} at ${MY_DATE}"

