#!/bin/bash
# name: swat_get_user_swat.sh
# desc: To create a spycam by installing 
#       all binaries and configuring swat_scripts
#       and their config files.
# usage: sudo ./swat_get_user_swat.sh
#
 export MY_SCRIPT="swat_get_user_swat.sh"
 export IN_USER="swat"
 export IN_GROUP="swat"
 #export PI_GROUPS=`groups pi|sed -e 's/^pi ://' -e 's/ /,/g' -e 's/\,users//g' -e 's/\,sudo//g' -e 's/\,wheel//g'`
 export PI_GROUPS="pi"
 userdel -r "${IN_USER}" 2>/dev/null
 groupdel "${IN_GROUP}" 2>/dev/null
 if [[ "`whoami`" == "${IN_USER}" ]];then
   {
     echo "${IN_USER}"
     exit 0 
   }
 else
   {
     CNT_USER_SWAT=`grep -w ${IN_USER} /etc/passwd|wc -l`
     CNT_GROUP_SWAT=`getent group ${IN_GROUP}|wc -l`
     MY_GROUP_SWAT=$(echo `getent group ${IN_GROUP}`)
     if [[ ( ${CNT_USER_SWAT} -eq 1 ) && ( ${CNT_GROUP_SWAT} -eq 1 ) ]];then
       {
         echo "${IN_USER}"
	 exit 0
       }
     else
       {
         sudo groupadd "${IN_GROUP}" 
         myRC=$?
         if [[ ${myRC} -ne 0 ]];then
           {
	     echo "#**********************************#"
             echo "# ${MY_SCRIPT} died on group create."
	     echo "# Tried to create group ${IN_GROUP}.       "
             echo "# Aborting with no action taken.    "	 
	     echo "#**********************************#"
	     exit -1
           }
         else
           {
	     : #DEBUG echo "#**********************************#"
	     #DEBUG echo "# Group ${IN_GROUP} added           "
	     #DEBUG echo "#**********************************#"
           }
         fi
     sudo useradd -m -g "${IN_GROUP}"  "${IN_USER}"
     myRC=$?
     if [[ ${myRC} -ne 0 ]];then
       {
	 echo "#**********************************#"
         echo "# ${MY_SCRIPT} died on useradd.     "
	 echo "# Tried to create user ${IN_USER}.  "
	 echo "# Aborting with no action taken.    "
	 echo "#**********************************#"
	 exit -1
       }
     fi
     echo "${IN_USER}:${IN_USER}"|chpasswd "${IN_USER}"  
     #DEBUG echo "#**********************************#"
     #DEBUG echo "# Created user ${IN_USER} with password=${IN_USER}"
     #DEBUG echo "#**********************************#"
     #sudo usermod -G "${PI_GROUPS}" "${IN_USER}"
         myRC=$?
         if [[ ${myRC} -eq 0 ]];then
           {
             echo "${IN_USER}"
	   }
	 else
	   {
	     echo "#**********************************#"
             echo "# ${MY_SCRIPT} died on group mod.   "
	     echo "# Tried to create group ${PI_GROUPS}."
             echo "# Aborting with no action taken.    "	 
	     echo "#**********************************#"
	     echo "# Listing groups...                 "
	     cat /etc/group|sort
	     exit -1
          }
        fi 
     }
   fi
   }
 fi
