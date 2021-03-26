#!/usr/bin/env bash
source pmon_functions.sh
source messages.sh

unset IFC;
unset VERBOSE;



function isRoot() {
	[ "$EUID" -ne 0 ] && norootMsg;
}
function isIfc() {
	local ifc="$1";
	ifconfig "$ifc" > /dev/null 2>&1
	if [ "$?" == 1 ]; then
		echo -e "${ifc}: ${NoIfc_msg}";
		return 1;
	else
		return 0;
	fi
}
function argparse() {
	options=$(getopt -n pmon -o I:hv: -l no-screen -l verbosity: -l help -- "$@")
	[ $? -eq 0 ] || exit 2;
	eval set -- "${options}";
	[ ${#} -lt 2 ] && { 
		nomac_msg;
		usageMsg;
	}
	while true; do
		case "$1" in
			-h) 
				helpMsg;;
			-I)
				shift
				isIfc "$1" || exit 2;
				IFC="$1";;
			-v)
				shift
				[[ "$1" =~ [0-5] ]] || verbosityError; usageMsg
				VERBOSE=$1;;
			--verbosity)
				shift;
				[[ $1 =~ [0-5] ]] || verbosityError
				VERBOSE=$1;;
			--no-screen)
				;;	

			--help) 
				helpMsg;;	
			--)
				shift
				[[ ! $1 ]] && usageMsg
				c=0 #count macs in $@
				for arg in $@; do
					if ! validMac $arg; then
						echo -e "${arg}: ${InvalidMac_m}"
						exit 2;
					fi
					macs[$c]="$arg";
					let c=c+1;
				done;
				break;;
		esac
		shift
	done
}
#########################
#       MAIN            #
#########################

function main() {
	#isRoot
	argparse $@;
	#selected IFCE
	[[ $IFC ]] && scan=$(arp-scan -l -I $IFC);
	# default IFACE
	[[ ! $IFC ]] && scan=$(arp-scan -l);
	for mc in ${macs[@]}; do
		pingIp "$mc";
	done
}
main $@
