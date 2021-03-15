#!/usr/bin/env bash
source pmon_functions.sh

#########################
#       MAIN            #
#########################

if [ "$EUID" -ne 0 ]; then #Root?
	echo -e "\n\n\e[101;1;97m ######ERROR!!! NOT ROOT. EXECUTE AS ROOT###### \e[0m\n\n";
	exit
fi
if [ $# == 0 ]; then #No arguments -> exit
	echo $NoMac_m
	exit
fi
#Interface or invalid mac?
if ! validmac "$1"; then #is a mac?
	if ! [[ "$1" == *":"* ]]; then  #Not contains ":", asume iface
		ifc="$1"
		ifconfig "$ifc" > /dev/null 2>&1
		if [ "$?" == 1 ]; then
			echo -e "\n\n\e[101;1;97m $NoIfc_m\e[0m\n\n"
			exit
		fi
		shift
	fi
fi
c=0 #count macs in $@
for arg in $@; do
	if ! validmac $arg; then #mac valid?
		echo -e "\n\n\e[101;1;97m$InvalidMac_m\e[0m\n\n"
		exit
	fi
	macs[$c]="$arg"
	c=$((c+1))
done
if [[ $ifc ]]; then #selected IFCE
	arp-scan -l -I $ifc > scan
else # default IFACE
	arp-scan -l > scan
fi
for mc in ${macs[@]}; do
	scan "$mc"
	ping_ip "$mc"
done
listening_
