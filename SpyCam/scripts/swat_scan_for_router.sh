# name: swat_scan_for_router.sh
# desc: Read config file and see if router is responding.
#       Sends back to calling program a 1 if responding.
# usage: ./swat_scan_for_router.sh
#
MY_SCRIPT_NAME=swat_scan_for_router.sh
MY_SCRIPT_DIR=/home/swat/scripts


 [[ ! -d "${MY_SCRIPT_DIR}" ]] && export MY_SCRIPT_DIR="."

 [[ -f "${MY_SCRIPT_DIR}/swat.config" ]] && source "${MY_SCRIPT_DIR}/swat.config"

 if [[ (! -z "${MY_ROUTER_NAME}" ) && ( -x "${MY_SCRIPT_DIR}/swat_scan_for_interface.sh" ) ]];then
      {
        for interface in `"${MY_SCRIPT_DIR}/swat_scan_for_interface.sh"`
          do
	    myCNT=`iwlist "${interface}" scan 2>/dev/null|awk -F ':' '/ESSID:/ {print $2;}'|grep "${MY_ROUTER_NAME}"|wc -l`
	    [[ $((myCNT)) -gt 0 ]] && { echo "${myCNT}"; break; }
	  done
      }
 fi
