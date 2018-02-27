#!/bin/bash
# name: startup_services.sh
# desc: Script to call on boot up from systemd.
# usage: ./startup_services.sh
#
MY_DATE=`date +%Y.%m.%d_%H.%M.%S`
MY_HOST=`uname -n`
###
### Start video feed
/opt/src/RPi_Cam_Web_Interface/start.sh
#echo "md1" > /var/www/cam/FIFO
###
###
echo "startup_services.sh completing on ${MYHOST} at ${MY_DATE}"

