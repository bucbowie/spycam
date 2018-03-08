# README.md
--------------------------------------------------
# Features
--------------------------------------------------
•	Easy installation. One script does all the work. One configuration file contains all the various settings found in the installed software configuration files. Personalize your setup in a single configuration file and have it update the other configuration files.

•	Built in motion detection can send you emails and video attachment of intruder when the motion detection is triggered. 

•	This solution applies updates/upgrades to the software distribution and installs the RPi Cam as taken from https://elinux.org/RPi-Cam-Web-Interface. It also updates V4L2 binaries and takes care of loading and installing any dependencies.

•	Optional IOT baked in. SpyCam turns off when it detects your presence. Turns back on when you leave.

•	Automagical static IP assignment for wireless network adapter (wlan0). Get email with RPi's wireless adapter new IP.

•	Optional External USB storage is automatically formatted, mounted and used to hold your historical videos captured by SpyCam.

•	Local Video Storage manages its own capacity and grooms off the oldest video when local space starts to fill up the SD card.

#
--------------------------------------------------
# Quick Installation
--------------------------------------------------
(see RPi_Zero_SpyCam.pdf for details)

1. Download solution and extract spycam_scripts.tar.
2. Copy spycam_scripts.tar to your Raspberry Pi. Install spycam_scripts.tar in the HOME directory of any user with SUDO privilege. Generally, the pi user has SUDO.
3. Untar (Extract) spycam_scripts.tar. Change directory to ./swat_scripts/boot.
4. Edit the swat.config to personalize your installation. See the PDF for details.
5. Attach an empty USB storage device if you want secondary storage to keep all your video recordings. 
6. Finally, change directory back to $HOME, where the install.sh script is located.
7. To install solution: sudo ./install.sh 
8. Go for coffee and return in 44 minutes. Open web browser to http://your-pi-I.P/cam and see the video camera. If you set up the configurations correctly from Step 4, then the camera will turn off in 1 minute. If you want to test your camera, simply turn off the wireless function on your cell phone and wait 4 minutes. The camera should go live after not seeing your cell phone. When you reenable the wireless function on your cell phone, within a minute the camera should stop capturing video.
