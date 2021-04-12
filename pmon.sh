#!/usr/bin/env bash
source ./lib/general
unset targetopt;
unset IFC;
unset VERBOSE;
unset TARGETS;
unset MACS;
VERBOSE=3
########################
#       MAIN            #
#########################

function argParse() {
	options=$(getopt -n pmon -o I:hv:t: -l no-screen -l verbosity: -l help -- "$@")
	[ $? -eq 0 ] || exit 2;
	eval set -- "${options}";
	while true; do
		case "$1" in
			-h) 
				helpMsg;;
			--help) 
				helpMsg;;	
			-I)
				shift
				isIfc "$1" || exit 2;
				IFC="$1";;
			-v)
				shift
				[[ "$1" =~ [0-5] ]] || verbosityError;
				VERBOSE=$1;;
			--verbosity)
				shift;
				[[ $1 =~ [0-5] ]] || verbosityError;
				VERBOSE=$1;;
			-t)
				targetopt=true;
				shift;
				TARGETS=("$1");
				shift && shift;
				for arg in $@; do
					TARGETS=("${TARGETS[@]}" "$arg")
					shift;
				done;
				break;;
			--)
				[ ${#} -lt 2 ] && { 
					nomac_msg;
					usageMsg;
				}
				shift;
				[[ ! $1 ]] && usageMsg;
				c=0 #count macs in $@
				for arg in $@; do
					if ! validMac $arg; then
						echo -e "${arg}: ${InvalidMac_m}";
						exit 2;
					fi
					MACS[$c]="$arg";
					let c=c+1;
				done;
				break;;
		esac;
		shift;
	done;
}

function main() {
	argParse "$@";
	isRoot;
	if [[ "$targetopt" ]]; then
		for target in ${TARGETS[@]}; do
			pingHost "$target" "$IFC"
		done;
	else
		#selected IFCE
		[[ $IFC ]] && {
			echo "Scanning arp table...";
			scan=$(arp-scan -l -I $IFC);
		}
		# default IFACE
		[[ ! $IFC ]] && {
			echo "Scanning arp table..."
			scan=$(arp-scan -l);
		}
		for mac in ${MACS[@]}; do
			host=$(macHaveIp "$mac");
			pingHost "$host" "$IFC";
		done
	fi
	keyEventListener;
}
main $@;
