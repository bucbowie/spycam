#!/bin/sh
# name : chgme.sh
# desc : grep with change string functionality
#
#   usage:
#   chgme.sh old-string new-string
#   will change all members within
#   the current directory
#
#   output:
#   saved as file-name; backup saved as file-name.chgme
#-----------------------------------------------------#
arg1=$1
arg2=$2
arg3=$3
arg4=$4
pattern=$1
replacement=$2
A="`echo | tr '\012' '\001' `"
 for file in *
  do
 echo $file
 cnt=`grep \-c $pattern $file`
 echo $cnt
  if [ $cnt -gt 0 ]
  then
   sed -e "s$A$pattern$A$replacement$A" $file > $file.new
   mv $file $file.chgme
   mv $file.new $file
  fi
  done

