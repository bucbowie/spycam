#!/bin/bash
# name: install.sh
# desc: To create a spycam by installing 
#       all binaries and configuring scripts
#       and their config files.
# usage: sudo ./install.sh
#
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
     echo "# to create dirctory /home/swat/scripts." 
     echo "#####################################"
     return 12
   }
 fi
 return 0
 }
##################################################
# MAIN LOGIC STARTS HERE
##################################################
 export MY_SCRIPT="install.sh"
 export MY_HOME=`pwd`
 export PATH=${PATH}:.
 set -avx
 [[ -d /home/swat ]] && { sudo userdel -f -r swat; }
 MY_USER=`swat_get_user_swat` 
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
     cd "${MY_HOME}"/swat_install
     sudo cp  ./install.sh /home/"${MY_USER}"
     sudo chown -R "${MY_USER}":sudo /home/"${MY_USER}"
     sudo chmod u+x  /home/"${MY_USER}"/install.sh
   }
 fi
 if [[ ( -d "${MY_HOME}"/scripts ) && ( -d "${MY_USER_DIR}" ) ]];then
   {
     cd "${MY_HOME}"/scripts
     sudo cp -R * "${MY_USER_DIR}"/.
     sudo chown -R root:"${MY_USER}" "${MY_USER_DIR}"
     sudo chmod -R 550 "${MY_USER_DIR}"
     sudo usermod -s /sbin/nologin "${MY_USER}"
   }
 fi

 cd "${MY_USER_DIR}"
 
 [[ ! -d /opt/src ]] && sudo mkdir /opt/src
 [[ ! -d /opt/src ]] && exit -1
 cd /opt/src

apt-get install -y debhelper dh-autoreconf autotools-dev autoconf-archive doxygen graphviz libasound2-dev libtool libjpeg-dev libqt4-dev libqt4-opengl-dev libudev-dev libx11-dev pkg-config udev make gcc git
apt-get install -y libv4l-dev uvcdynctrl build-essential automake vim arp-scan ssmtp  mailutils mpack
myCNT=`sudo grep bcm2835-v4l2 /etc/modules|wc -l`
[[ $((myCNT)) -eq 0 ]] && { echo "bcm2835-v4l2" >> /etc/modules; }
myCNT=`sudo grep bcm2835-v4l2 /etc/modules|wc -l`
[[ $((myCNT)) -gt 0 ]] && { sudo modprobe bcm2835-v4l2; }

[[ ! -d ./v4l-utils ]] && { git clone http://git.linuxtv.org/v4l-utils.git; }

 if [[ -d ./v4l-utils ]];then
   {
     MY_V4L2CTL=`v4l2-ctl --list-devices|grep '/dev/video'|wc -l`
     if [[ ${MY_V4L2CTL} -eq 0 ]];then
        {
          cd ./v4l-utils
          ./bootstrap.sh && ./configure &&  make && make install
	}
     fi
   }
 else
   {
     echo "Died somewhere in ./v4l-utils"
     exit -1
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

[[ ! -d ./RPi_Cam_Web_Interface ]] && { git clone https://github.com/silvanmelchior/RPi_Cam_Web_Interface.git; }
cd ./RPi_Cam_Web_Interface
sed -i 's/rpicamdir=\\"html\\"/rpicamdir=\\"cam\\"/' ./install.sh
sed -i 's/webserver=\\"apache\\"/webserver=\\"nginx\\"/' ./install.sh
sed -i 's/read -r rpicamdir/rpicamdir="cam"/' ./install.sh
sed -i 's/response=$?/response=1/' ./install.sh
echo "chmod u+x /var/www/cam/macros/*.sh" >> ./install.sh
./install.sh q

 cd "${MY_HOME}" 

 if [[ -d scripts ]];then
   {
        cd scripts
	chown root:root ./cron/root
        [[ -f /var/spool/cron/crontabs/root ]] && { sudo crontab -l > a.a; }
	cat ./cron/root >> a.a 
	sudo crontab ./a.a
	mv ./cron/root /tmp 
	rm -rf ./cron
	chown root:root ./boot/swat.config
	sudo mv ./boot/swat.config /boot/swat.config
	rm -rf ./boot
	chmod u+x *.sh
	[[ -f ./swat.config ]] && { mv ./swat.config /tmp/. ;}
	sudo ln -s /boot/swat.config ./swat.config
	[[ -f /boot/swat.config ]] && { source /boot/swat.config; }
	sudo cp swat.service /lib/systemd/system/swat.service
	cd /etc/systemd/system
	sudo ln -s /lib/systemd/system/swat.service swat.service
	sudo systemctl enable swat.service
	sudo systemctl start swat.service
        sudo sed -i.bak '/^exit 0/isudo systemctl start swat' /etc/rc.local
	if [[ -d /sys/block/sda ]];then
	  {
	    [[ ! -d /media/cam ]] && { mkdir /media/cam; chmod 777 /media/cam; }
	    sudo apt-get install -y ntfs-3g
	    sudo cp /etc/fstab /etc/fstab.pristine
	    echo "/dev/sda1 /media/cam ntfs-3g defaults,notime,nofail,soft,rw 0 0" >> /etc/fstab
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
	      }
	    fi
	  }
	fi
   }
 fi

sudo sed -i 's/mailhub=mail/mailhub=smtp.gmail.com:587/' /etc/ssmtp/ssmtp.conf
echo "AuthUser=${MY_EMAIL_ADDRESS}" >> /etc/ssmtp/ssmtp.conf
echo "AuthPass=${MY_EMAIL_PW}" >> /etc/ssmtp/ssmtp.conf
echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
[[ ! -z "${MY_CAMERA_NAME}" ]] && { sed -i 's/annotation RPi Cam/annotation '${MY_CAMERA_NAME}'/' /etc/raspimjpeg;  } 
sed -i 's/rotation 0/rotation 90/' /etc/raspimjpeg
sed -i 's/motion_detection false/motion_detection true/' /etc/raspimjpeg
sed -i 's/mycam/'${MY_CAMERA_NAME}'/' /opt/src/RPi_Cam_Web_Interface/www/config.php
sudo rm -rf "${MY_HOME}"/scripts "${MY_HOME}"/swat_install "${MY_HOME}"/install.sh /home/"${MY_USER}"/swat_install /home/"${MY_USER}"/install.sh &
sudo systemctl reboot
