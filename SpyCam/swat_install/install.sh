#!/bin/bash
# name: install.sh
# desc: To create a spycam by installing 
#       all binaries and configuring scripts
#       and their config files.
# usage: sudo ./install.sh
#
##################################################
# MAIN LOGIC STARTS HERE
##################################################
 export MY_SCRIPT="install.sh"
 export MY_HOME=`pwd`
 export PATH=${PATH}:.
 set -avx
 [[ -f /etc/rc.local.swat ]] && { mv  /etc/rc.local.swat  /etc/rc.local > /tmp/local.move2 2>&1; }
 
##########
exit
##########
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
	sudo cp swat.service /lib/systemd/system/swat.service
	cd /etc/systemd/system
	sudo ln -s /lib/systemd/system/swat.service swat.service
	sudo systemctl enable swat.service
	sudo systemctl start swat.service
        sudo sed -i.bak '/exit 0/isudo systemctl start swat' /etc/rc.local
   }
 fi

sudo sed -i 's/mailhub=mail/mailhub=smtp.gmail.com:587/' /etc/ssmtp/ssmtp.conf
echo "AuthUser=bucbowie@gmail.com" >> /etc/ssmtp/ssmtp.conf
echo "AuthPass=lscggvjtgmzlcuca" >> /etc/ssmtp/ssmtp.conf
echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf
echo "UseSTARTTLS=YES" >> /etc/ssmtp/ssmtp.conf
sed -i 's/rotation 0/rotation 90/' /etc/raspimjpeg
sed -i 's/motion_detection false/motion_detection true/' /etc/raspimjpeg
sudo systemctl reboot
