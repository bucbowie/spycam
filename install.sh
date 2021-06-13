#!/bin/bash
# name: install.sh
# desc: To create a spycam by installing 
#       all binaries and configuring swat_scripts
#       and their config files.
# usage: sudo ./install.sh
#
#Askew20180319.001 Test Apache for WEBDAV
set -a
#------------------------------------------#
 function update_binaries() {
#------------------------------------------#
 sudo apt-get -y update
 myRC=$?
 if [[ $myRC -ne 0 ]];then
   { 
     echo "#####################################"
     echo "# ${MY_SCRIPT} has issues in function"
     echo "# update_binaries.                   "
     echo "# apt-get update RC=${myRC}          "
     echo "# Aborting program with no action    "
     echo "# taken other than what was updated  "
     echo "# in function update_binaries before "
     echo "# this error.                        "
     echo "#####################################"
     exit -1
   }
 fi

 sudo apt-get -y upgrade
 myRC=$?
 if [[ $myRC -ne 0 ]];then
   { 
     echo "#####################################"
     echo "# ${MY_SCRIPT} has issues in function"
     echo "# update_binaries.                   "
     echo "# apt-get upgrade RC=${myRC}         "
     echo "# Aborting program with no action    "
     echo "# taken other than what was updated  "
     echo "# in function update_binaries before "
     echo "# this error.                        "
     echo "#####################################"
     exit -1
   }
 fi
 sudo apt-get -y dist-upgrade  
 myRC=$?
 if [[ $myRC -ne 0 ]];then
   { 
     echo "#####################################"
     echo "# ${MY_SCRIPT} has issues in function"
     echo "# update_binaries.                   "
     echo "# apt-get dist-upgrade RC=${myRC}    "
     echo "# Aborting program with no action    "
     echo "# taken other than what was updated  "
     echo "# in function update_binaries before "
     echo "# this error.                        "
     echo "#####################################"
     exit -1
   }
 fi
 sudo rpi-update -y
 myRC=$?
 if [[ $myRC -ne 1 ]];then
   { 
     echo "#####################################"
     echo "# ${MY_SCRIPT} has issues in function"
     echo "# update_binaries.                   "
     echo "# rpi-update  RC=${myRC}             "
     echo "# Aborting program with no action    "
     echo "# taken other than what was updated  "
     echo "# in function update_binaries before "
     echo "# this error.                        "
     echo "#####################################"
     exit -1
   }
 fi

 sudo apt-get install -y arp-scan
 }
#------------------------------------------#
 function swat_format_usb()  {
#------------------------------------------#
 if [[ `sudo mount|grep '/media/cam'|grep vfat|wc -l` -gt 0 ]];then
   {
	     echo "#####################################"
	     echo "# install.sh sees /media/cam already "
	     echo "# mounted. Skip format USB with no   "
	     echo "# action taken on USB or /media/cam. "
	     echo "# ...Processing continues...         "
	     echo "#####################################"
	     return 4
   }
 fi
 if [[ `df -k|grep '/media/cam'|wc -l` -gt 0 ]];then
   {
	     echo "#####################################"
	     echo "# install.sh sees /media/cam already "
	     echo "# mounted. Skip format USB with no   "
	     echo "# action taken on USB or /media/cam. "
	     echo "# ...Processing continues...         "
	     echo "#####################################"
	     return 4
   }
 fi

 if [[ -L /sys/block/sda ]];then
   {
    echo "#####################################"
    echo "# USB build: /sys/block/sda is found"
    echo "#####################################"
    [[ ! -d /media/cam ]] && { sudo mkdir -p /media/cam; sudo chmod 777 /media/cam; }
    if [[ -e "${SCRIPT_DIR}"/swat_format_usb.sh ]];then
       {
          echo "#####################################"
	  echo "#USB build: running swat_format_usb.sh"
          echo "#####################################"
	  sudo "${SCRIPT_DIR}"/swat_format_usb.sh
	  myRC=$?
	  if [[ ${myRC} -eq 0 ]];then
	     {
	       sudo cp /etc/fstab /etc/fstab.pristine
	       echo "/dev/sda1 /media/cam vfat defaults,noatime,nofail,rw 0 0" | sudo tee -a /etc/fstab
	       sudo umount -l /media/cam
	       sleep 2
	    }
	 fi
	 sudo mount -a
	 myRC=$?
	 if [[ ${myRC} -ne 0 ]];then
	   {
	     sudo mv /etc/fstab.pristine /etc/fstab
	     sudo rm -rf /media/cam
	     echo "#####################################"
	     echo "# install.sh unable to mount         "
	     echo "# external drive. Mount returned: ${myRC}"
	     echo "# Suggest command: dmesg|grep sd     "
	     echo "# and look for the mount messages    "
	     echo "#####################################"
	     return 12
	   }
	 fi
       }
    fi
   return 0
   }
 return 8
 fi
 }
#------------------------------------------#
 function swat_get_user_swat() {
#------------------------------------------#
 if [[ ! -d ./swat_install ]]; then
   {
     echo "#####################################"
     echo "# install.sh running function        "
     echo "# swat_get_user_swat failed.         "
     echo "# Aborting.                          "
     echo "# Directory ./swat_install not found."
     echo "#####################################"
     return 12
   }
 fi
 cd ./swat_install
 sudo chmod u+x *.sh

 if [[ ! -x ./swat_get_user_swat.sh ]]; then
   {
     echo "#####################################"
     echo "# install.sh running function        "
     echo "# swat_get_user_swat failed.         "
     echo "# Aborting.                          "
     echo "# Script swat_get_user_swat.sh not found."
     echo "#####################################"
     return 12
   }
 fi
 sudo ./swat_get_user_swat.sh
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "#####################################"
     echo "# install.sh running function        "
     echo "# swat_get_user_swat failed.         "
     echo "# Aborting.                          "
     echo "# Script swat_get_user_swat.sh failed"
     echo "# to create user swat.               " 
     echo "#####################################"
     return 12
   }
 fi
 return 0
 }
#------------------------------------------#
 function swat_set_dir_swat() {
#------------------------------------------#
 if [[ ! -d ./swat_install ]]; then
   {
     echo "#####################################"
     echo "# install.sh running function        "
     echo "# swat_get_user_swat failed.         "
     echo "# Aborting.                          "
     echo "# Directory ./swat_install not found."
     echo "#####################################"
     return 12
   }
 fi
 cd ./swat_install
 sudo chmod u+x *.sh
 if [[ ! -x ./swat_set_dir_swat.sh ]]; then
   {
     echo "#####################################"
     echo "# install.sh running function        "
     echo "# swat_set_dir_swat failed.         "
     echo "# Aborting.                          "
     echo "# Script swat_set_dir_swat.sh not found."
     echo "#####################################"
     return 12
   }
 fi
 sudo ./swat_set_dir_swat.sh
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "#####################################"
     echo "# install.sh running function        "
     echo "# swat_set_dir_swat failed.         "
     echo "# Aborting.                          "
     echo "# Script swat_set_dir_swat.sh failed"
     echo "# to create dirctory /home/swat/${SCRIPT_DIR}." 
     echo "#####################################"
     return 12
   }
 fi
 return 0
 }
##################################################
# MAIN LOGIC STARTS HERE
##################################################
 apt-get install -y dos2unix
 export MY_SCRIPT="install.sh"
 export MY_HOME=`pwd`
 export SCRIPT_DIR="swat_scripts"
 export SERVER_NAME=`hostname` 
 export SERVER_IP=`ifconfig|grep inet|egrep -v "127.0.0.1|inet6"|awk '{print }'|head -1` 
 [[ -z "${SERVER_IP}" ]] && { export SERVER_IP="${SERVER_NAME}"; }
 sudo `which dos2unix` "${MY_HOME}"/"${SCRIPT_DIR}"/* "${MY_HOME}"/swat_install/* "${MY_HOME}"/swat_scripts/boot/swat.config  
 sudo chmod -R u+x "${MY_HOME}"/swat_scripts/*.sh "${MY_HOME}"/swat_install/*.sh
 export PATH=${PATH}:.
 [[ -d /home/swat ]] && { sudo userdel -f -r swat; }
 MY_USER=`swat_get_user_swat` 
 echo "MY_USER=${MY_USER}"
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "#####################################"
     echo "# install.sh running function        "
     echo "# swat_get_user_swat failed.         "
     echo "# Aborting.                          "
     echo "# Script swat_get_user_swat.sh returned"
     echo "# with RC=${myRC}                    " 
     echo "#####################################"
     exit -1
   }
 fi
 sudo usermod -s /sbin/nologin "${MY_USER}" 
 MY_USER_DIR=`swat_set_dir_swat`
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "#####################################"
     echo "# install.sh running function        "
     echo "# swat_set_dir_swat failed.         "
     echo "# Aborting.                          "
     echo "# Script swat_set_dir_swat.sh returned"
     echo "# with RC=${myRC}                    " 
     echo "#####################################"
     exit -1
   }
 fi
 
 if [[ -d "${MY_HOME}"/swat_install ]];then
   {
     `which dos2unix` "${MY_HOME}"/swat_install/*
     cd "${MY_HOME}"
     sudo cp  ./install.sh /home/"${MY_USER}/."
     sudo chown -R "${MY_USER}":sudo /home/"${MY_USER}"
     sudo chmod u+x  /home/"${MY_USER}"/install.sh
   }
 fi
 if [[ ( -d "${MY_HOME}"/"${SCRIPT_DIR}" ) && ( -d "${MY_USER_DIR}" ) ]];then
   {
     sudo `which dos2unix` "${MY_HOME}"/"${SCRIPT_DIR}"/*
     cd "${MY_HOME}"/"${SCRIPT_DIR}"
     sudo cp -R * "${MY_USER_DIR}"/.
     sudo chown -R root:"${MY_USER}" "${MY_USER_DIR}"
     sudo chmod -R 550 "${MY_USER_DIR}"
     sudo `which dos2unix` "${MY_USER_DIR}"/* 
     sudo usermod -s /sbin/nologin "${MY_USER}"
   }
 else
   {
     echo "#####################################"
     echo "# install.sh FATAL error!           #"
     echo "#-----------------------------------#"
     echo "# After running function             "
     echo "# swat_set_dir_swat failed to create "
     echo "# either                             "
     echo "#/home/\${MY_USER} = /home/${MY_USER}"
     echo "# or                                 "
     echo "# \${MY_USER_DIR}=${MY_USER_DIR}     "
     echo "#  ----- \>\>\>  Aborting   \<\<\< -----"
     echo "# with no action taken.              "
     echo "#####################################"
     [[ -d /home/swat ]] && { sudo userdel -f -r swat; }
     exit -1
   }
 fi
 #
 echo "##################################################"
 echo "# SWAT building Root Certificate Authority" 
 echo "##################################################"
 [[ -x /home/swat/${SCRIPT_DIR}/swat_cr_CA.sh ]] && { . /home/swat/${SCRIPT_DIR}/swat_cr_CA.sh; }
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "#####################################"
     echo "# W A R N I N G                      "
     echo "# - - - - - - - - - - - - - - - - - -"
     echo "# /home/swat/${SCRIPT_DIR}/swat_cr_CA.sh failed."
     echo "# Script returned: ${myRC}.          "
     echo "# Skipping ROOT CERTIFICATE build.   "
     echo "# Processsing continues...           "
     echo "#                                    "
   }
 fi
 echo "##################################################"
 echo "# SWAT building Certificate for SSL/TLs" 
 echo "##################################################"
 [[ -x /home/swat/${SCRIPT_DIR}/swat_cr_cert.sh ]] && { . /home/swat/${SCRIPT_DIR}/swat_cr_cert.sh; }
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "#####################################"
     echo "# W A R N I N G                      "
     echo "# - - - - - - - - - - - - - - - - - -"
     echo "# /home/swat/${SCRIPT_DIR}/swat_cr_cert.sh failed."
     echo "# Script returned: ${myRC}.          "
     echo "# Skipping CERTIFICATE build.        "
     echo "# Processsing continues...           "
     echo "#                                    "
   }
 fi

 echo "##################################################"
 echo "# SWAT user build successfully completed. Starting software installs." 
 echo "##################################################"
 echo ""
 echo "#---------------------------------------------#"
 echo "# Software Upgrade. Bring Operating System current." 
 echo "#---------------------------------------------#"

 update_binaries
 
 echo "" 
 echo "##################################################"
 echo "# USB Management. If present, clean, format and mount." 
 echo "##################################################"
 echo "#--------------------------------------------#"
 echo "# Test if there is a usb inserted, if so,     "
 echo "# then attempt to format and mount. Abort     "
 echo "# script if usb inserted and format/mount fails."
 echo "#--------------------------------------------#"
 swat_format_usb
 myRC=$?
 if [[ ${myRC} -gt 4 ]];then
   {
     echo "#####################################"
     echo "# function swat_format_usb.sh        "
     echo "# failed. Aborting with not action   "
     echo "# taken.                             "
     echo "# ---\> Either:                      "
     echo "# 1. Remove USB and rerun this script"
     echo "# or                                 "
     echo "# 2. Investigate why format/mount    "
     echo "#    mount failed and take action    "
     echo "#    to resolve. Then rerun this     "
     echo "#    script.                         "
     echo "#####################################"
     exit -1
   }
 fi

 
 [[ ! -d /opt/src ]] && sudo mkdir /opt/src
 [[ ! -d /opt/src ]] && exit -1
 cd /opt/src
 echo "##################################################"
 echo "# Install dependencies and tools need for camera." 
 echo "##################################################"

apt-get install -y debhelper dh-autoreconf autotools-dev autoconf-archive doxygen graphviz libasound2-dev libtool libjpeg-dev libqt4-dev libqt4-opengl-dev libudev-dev libx11-dev pkg-config udev make gcc git
apt-get install -y libv4l-dev uvcdynctrl build-essential automake vim arp-scan msmtp msmtp-mta  mailutils mpack
myCNT=`sudo grep bcm2835-v4l2 /etc/modules|wc -l`
[[ $((myCNT)) -eq 0 ]] && { echo "bcm2835-v4l2" >> /etc/modules; }
myCNT=`sudo grep bcm2835-v4l2 /etc/modules|wc -l`
[[ $((myCNT)) -gt 0 ]] && { sudo modprobe bcm2835-v4l2; }
 
 [[ -d ./v4l-utils ]] && { sudo rm -rf ./v4l-utils; }
 echo "#--------------------------------------------#"
 echo "# Download and prepare V4L-Utils              "
 echo "#--------------------------------------------#"

[[ ! -d ./v4l-utils ]] && { git clone http://git.linuxtv.org/v4l-utils.git; }

 if [[ -d ./v4l-utils ]];then
   {
          echo "#--------------------------------------------#"
          echo "# Installing V4L-Utils                        "
          echo "#--------------------------------------------#"
          cd ./v4l-utils
          ./bootstrap.sh && ./configure &&  make && make install
	}
 fi
 myRC=$?
 if [[ $((myRC)) -gt 0 ]];then
   {
     echo "Died somewhere in compiling ./v4l-utils"
     exit -1
   }
 fi

 cd /opt/src
 echo "##################################################"
 echo "# Install camera software.                        " 
 echo "##################################################"
 [[ -d ./RPi_Cam_Web_Interface ]] && { sudo rm -rf ./RPi_Cam_Web_Interface; }

 echo "#--------------------------------------------#"
 echo "# Download and prepare RPi_Cam_Web_Interface  "
 echo "#--------------------------------------------#"
 [[ ! -d ./RPi_Cam_Web_Interface ]] && { git clone https://github.com/silvanmelchior/RPi_Cam_Web_Interface.git; }
 cd ./RPi_Cam_Web_Interface
 sed -i 's/rpicamdir=\\"html\\"/rpicamdir=\\"cam\\"/' ./install.sh
 sed -i 's/webserver=\\"apache\\"/webserver=\\"nginx\\"/' ./install.sh
 sed -i 's/read -r rpicamdir/rpicamdir="cam"/' ./install.sh
 sed -i 's/response=$?/response=0/' ./install.sh #Askew20210608 - chg from 1 to 0
 echo "chmod u+x /var/www/cam/macros/*.sh" >> ./install.sh
 echo "#--------------------------------------------#"
 echo "# Silent install RPi_Cam_Web_Interface        "
 echo "#--------------------------------------------#"
 #
 ./install.sh q
 echo ""
 echo "###############################################"
 echo "# SOFTWARE INSTALLS COMPLETED.                #"
 echo "# Starting POST INSTALL set up                #"
 echo "###############################################"
 echo ""
 echo "#--------------------------------------------#"
 echo "# Copy configuration files and update settings."
 echo "#--------------------------------------------#"
 if [[ -d "${MY_USER_DIR}" ]];then
   {
        cd "${MY_USER_DIR}" 
	chown root:root ./cron/root
        [[ -f /var/spool/cron/crontabs/root ]] && { sudo crontab -l > a.a; }
	cat ./cron/root >> a.a 
	sudo crontab ./a.a
	mv ./cron/root /tmp 
	rm -rf ./cron
	sudo chown root:root ./boot/swat.config
	sudo mv ./boot/swat.config /boot/swat.config
	sudo chown root:root /boot/swat.config
        `which dos2unix` /boot/swat.config
	sudo rm -rf ./boot
	sudo chmod u+x *.sh
	[[ -f ./swat.config ]] && { sudo mv ./swat.config /tmp/. ;}
	sudo cp  /boot/swat.config ./swat.config
        `which dos2unix` /home/swat/swat_scripts/swat.config
	[[ -f /boot/swat.config ]] && { source /boot/swat.config; }
	sudo cp swat.service /lib/systemd/system/swat.service
	cd /etc/systemd/system
	sudo ln -s /lib/systemd/system/swat.service swat.service
        sudo systemctl daemon-reload 
	sudo systemctl enable swat.service
	sudo systemctl daemon-reload
        sudo systemctl start swat.service
        sudo sed -i.bak '/^exit 0/isudo systemctl start swat' /etc/rc.local
	[[ $? -ne 0 ]] && { sudo mv  /etc/rc.local.bak /etc/rc.local; }
    }
 fi
 echo "#--------------------------------------------#"
 echo "# Configure camera settings.                  "
 echo "#--------------------------------------------#"
 sudo echo -e "account\t\tdefault" > /etc/msmtprc
 sudo echo -e "auth\t\ton" >> /etc/msmtprc
 sudo echo -e "tls\t\ton"   >> /etc/msmtprc
 sudo echo -e "tls_starttls\ton" >> /etc/msmtprc
 sudo echo -e "logfile\t\t/var/log/msmtp" >> /etc/msmtprc
 sudo echo -e "host\t\tsmtp.gmail.com" >> /etc/msmtprc
 sudo echo -e "port\t\t587" >> /etc/msmtprc
 sudo echo -e "from\t\t${MY_EMAIL_ADDRESS}" >> /etc/msmtprc
 sudo echo -e"user\t\t${MY_EMAIL_ADDRESS}" >> /etc/msmtprc
 sudo echo -e "password\t\t${MY_EMAIL_PW}"  >> /etc/msmtprc
 sudo echo -e "syslog\t\tLOG_MAIL" >> /etc/msmtprc
 sudo chown root:msmtp  /etc/msmtprc
 sudo chmod 660 /etc/msmtprc
 
 echo "#--------------------------------------------#"
 echo "# Enabling motion - change /etc/default/motion"
 echo "#--------------------------------------------#"
 sudo sed -i 's/start_motion_daemon=no/start_motion_daemon=yes/g' /etc/default/motion


 echo "#--------------------------------------------#"
 echo "# Setting /etc/raspimjpeg                    #"
 echo "#--------------------------------------------#"
 [[ ! -z "${MY_CAMERA_NAME}" ]] && { sudo sed -i 's/annotation RPi Cam/annotation '${MY_CAMERA_NAME}'/' /etc/raspimjpeg;  } 
 sudo sed -i 's/rotation 0/rotation 90/' /etc/raspimjpeg
 sudo sed -i 's/motion_detection false/motion_detection true/' /etc/raspimjpeg
 [[ ! -z "${MY_CAMERA_NAME}" ]] && { sudo sed -i 's/mycam/'${MY_CAMERA_NAME}'/' /opt/src/RPi_Cam_Web_Interface/www/config.php; }
 if [[ -f /etc/apache2/apache.conf ]]; then
   {
	 echo "#--------------------------------------------#"
	 echo "# Build Apache SSL                           #"
	 echo "#--------------------------------------------#"
	 echo "LoadModule ssl_module modules/mod_ssl.so" > /tmp/a.a
	 echo "Listen 443" >> /tmp/a.a
	 echo "<IfModule mod_ssl.c>" >> /tmp/a.a
	 sudo cat /etc/apache2/sites-available/raspicam.conf|grep -i [a-z]|sed -e 's/:80/:443/' -e '/DocumentRoot/a     ServerName '${SERVER_NAME} >> /tmp/a.a
	 sudo sed -i -e '/ServerName/a     SSLEngine on'  /tmp/a.a
	 sudo sed -i -e  '/SSLEngine/a     SSLCertificateFile /etc/swat/conf.d/CA/'${SERVER_NAME}'.crt'   /tmp/a.a
	 sudo sed -i -e '/SSLCertificateFile/a    SSLCertificateKeyFile /etc/swat/conf.d/CA/private/'${SERVER_NAME}'.key' /tmp/a.a
	 echo "</IfModule>" >> /tmp/a.a
	 cat /tmp/a.a >> /etc/apache2/sites-available/raspicam.conf
	 [[ -f /etc/apache2/apache2.conf ]] && { sudo echo "ServerName ${SERVER_NAME}" >> /etc/apache2/apache2.conf; }
	 sudo a2enmod ssl
	 sudo a2enmod headers
	 sudo apachectl -k restart
   }
 fi
 if [[ -f /etc/nginx/sites-enabled/rpicam ]];then
   {
	 echo "#--------------------------------------------#"
	 echo "# Build Nginx SSL                            #"
	 echo "#--------------------------------------------#"
	 cd /etc/nginx/sites-enabled 
         [[ ! -f ./rpicam.pristine ]] && { sudo cp ./rpicam ./rpicam.pristine; }
	 sudo sed -i '/listen   \[\:\:\]/a\\tlisten 443 ssl; '  ./rpicam 
         sudo sed -i '/server_name/s/localhost/'`hostname`'/'   ./rpicam
         sudo sed -i '/server_name/a\\tssl_certificate_key /etc/swat/conf.d/CA/private/'`hostname`'.key;' ./rpicam
         sudo sed -i '/server_name/a\\tssl_certificate /etc/swat/conf.d/CA/'`hostname`'.crt;' ./rpicam
         sudo systemctl restart nginx
         myRC=$?
         if [[ ${myRC} -ne 0 ]];then
           {
	     echo "##############################################"
             echo "# Error in install.sh !                      #"
             echo "# Aborting Nginx changes with no action taken#"
             echo "# - - - - - - - - - - - - - - - - - - - - - -#"
             echo "# Unable to use SSL settings:                 "
             echo "# ssl_certificate /etc/swat/conf.d/CA/`hostname`.crt" 
             echo "# ssl_certificate_key  /etc/swat/conf.d/CA/private/`hostname`.key" 
             echo "# ---> Returning Nginx                        "
             echo "#      back to original HTTP settings.        "
	     echo "##############################################"
             sudo cp ./rpicam.pristine ./rpicam
             sudo systemctl restart nginx
             myRC=$?
             [[ ${myRC} -ne 0 ]] && { echo -e "\n#\n#\n# FATAL ERROR in Nginx!. It's hosed!\n#\n#"; }
           }
         fi
   }
 fi
 echo "#--------------------------------------------#"
 echo "# Clean up and reboot.                        "
 echo "#--------------------------------------------#"
# echo "sudo rm -rf ${MY_HOME}/${SCRIPT_DIR} ${MY_HOME}/swat_install ${MY_HOME}/install.sh /home/${MY_USER}/swat_install /home/${MY_USER}/install.sh &"
# sudo rm -rf "${MY_HOME}"/"${SCRIPT_DIR}" "${MY_HOME}"/swat_install "${MY_HOME}"/install.sh /home/"${MY_USER}"/swat_install /home/"${MY_USER}"/install.sh &
 echo "###############################################"
 echo "# COMPLETED Install and Clean up. Recapping   #"
 echo "# SSL CA and CERT builds:                     #"
 echo "# See /var/log/swat.log for details on SSL    #"
 echo "###############################################"
sudo systemctl reboot
