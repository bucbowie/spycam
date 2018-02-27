#!/bin/bash
# name: swat_scan_for_interface.sh
# desc: Read config file and see if router is responding.
#       Sends back to calling program a 1 if responding.
# usage: ./swat_scan_for_interface.sh
#
MY_SCRIPT_NAME=swat_scan_for_interface.sh
MY_SCRIPT_DIR=/home/swat/scripts


 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 [[ -f "${MY_SCRIPT_DIR}/swat.config" ]] && source "${MY_SCRIPT_DIR}/swat.config"

 ip -f inet addr|egrep -v "lo:|127.0...1"|egrep "^[0-9]|inet"|awk -v ORS=' ' '{print $2;}'|awk '{print $1, $3, $5, $7}'|sed 's/://g' 
