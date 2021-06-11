#!/usr/bin/bash
MY_HDD="/dev/sda"
MY_PART="/dev/sda1"
MY_MOUNT="/media/cam"
AM_I_MOUNTED=`mount|grep "${MY_MOUNT}"|wc -l`
if [[ ${AM_I_MOUNTED} -gt 0 ]];then
  {
    echo "##################################"
    echo "# Warning! swat_format_usb.sh     "
    echo "# Aborting with no action taken.  "
    echo "# ${MY_MOUNT} is already mounted. "
    echo "#                                 "
    echo "# Save content on ${MY_MOUNT}     "
    echo "# to another location if you want "
    echo "# to save your work on ${MY_MOUNT}"
    echo "# then issue the command:         "
    echo "# ------------------------------- "
    echo "# umount -l ${MY_MOUNT}           "
    echo "# ------------------------------- "
    echo "# allowing this script to continue"
    echo "##################################"
    exit -1
   }
 fi
DISK_TYPE=`fdisk -l /dev/sda|sed -n '/^Device/,\$p'|tail -1|awk '{print $6}'`
 if [[ ${DISK_TYPE} -eq 7 ]];then
   { 
      echo "/dev/sda1 already set up"
   }
 else
   {
	for i in /dev/sda
	  do
	    echo "o
	    n
	    p



	    t
	    7
	    w
	    "|fdisk "${i}";mkfs\.vfat "${i}1";done
	 myRC=$?
	 if [[ ${myRC} -ne 0 ]];then
	   {
	     echo "##################################"
	     echo "# Error!   swat_format_usb.sh     "
	     echo "# Aborting with no action taken.  "
	     echo "# swat_format_usb.sh ended with   "
	     echo "# return code: ${myRC}.           "
	     echo "# --> The last command to run was:"
	     echo "# ------------------------------- "
	     echo "# mkfs\.vfat ${MY_PART}           "
	     echo "# ------------------------------- "
	     echo "##################################"
	     [[  -d "${MY_MOUNT}" ]] && { sudo rm -rf "${MY_MOUNT}"; }
	   }
	 else
	   {
	     sudo partprobe
	     echo "##################################"
	     echo "# New Partition created. Here are "
	     echo "# the details:                    "
	     fdisk -l /dev/sda1|awk '{print "# "$0}'
	     echo "##################################"
	   }
	 fi
     }
  fi
 [[ ! -d "${MY_MOUNT}" ]] && { sudo mkdir "${MY_MOUNT}"; }
 sudo mount -t vfat -o defaults,noatime,rw,nofail "${MY_PART}" "${MY_MOUNT}"
 myRC=$?
 if [[ ${myRC} -ne 0 ]];then
   {
     echo "##################################"
     echo "# Error!   swat_format_usb.sh     "
     echo "# Aborting with no action taken.  "
     echo "# --\> unable to mount ${MY_MOUNT}"
     echo "# Last command issued:            "
     echo "# ------------------------------- "
     echo "# mount -t vfat -o defaults,noatime,rw,nofail ${MY_PART} ${MY_MOUNT}"
     echo "##################################"
   }
 else
   {
     echo "##################################"
     echo "# New Mount created. Here are     "
     echo "# the details:                    "
     df -k|grep ${MY_MOUNT}|awk '{print "# "$0}'
     echo "##################################"
   }
 fi
