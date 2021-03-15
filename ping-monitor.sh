#!/usr/bin/env bash
########################
#   GLOBAL VARIABLES  #
######################
LOG="event.log"
DATE=$(date)
declare -A ips #Asociative array ips[mac-->IP, mac---IP,...]
source messages.sh
#######################
#     FUNCTIONS       #
#######################
function isroot(){ #root?
	if [ "$EUID" -ne 0 ]; then
		echo -e "\n\n\e[101;1;97m $NoRoot_m \e[0m\n\n"
		exit
	fi
}
function validmac() { #valid mac?
	echo "$1" | egrep "^^([a-fA-F0-9]{2}:){5}([a-fA-F0-9]{2})$"  > /dev/null
	if [ "$?" == 1 ]; then
			return 1
	else
			return 0
	fi
}
function scan() {
	mac="$1"
	ip=$(cat scan | grep "$mac" | awk '{print $1}')
	if ! [[ $ip ]]; then #Not in arp table
		echo -e "\n\n\e[101;1;97m$IpNotFound_m\e[0m\n\n"
	else
		ips[$mac]="$ip"
	fi
}
function ping_ip() {
	
	if [[ "${ips[$1]}" == "" ]]; then #no ip from mac
		return
	elif [ "$ifc" ]; then #selected iface
		aae=0 #alive after errors
		ping -O "${ips[$1]}" -I "$ifc" | while read -r line; do #ping and read lines
		#no answer ---> eroor mode ---> alert & log
		echo -e "\n${ips[$1]}: "
		if [[ "$line" =~ "Unreachable" ]] || [[ "$line" =~ "no answer" ]]; then
			if [[ "$errormode" == 1 ]]; then
				echo -e " \e[101;1;97m $Warning_m $line\e[m"
			else
				echo -e "\e[101;1;97m$line\e[m"
				echo -e "\e[101;1;97m$date $line\e[m" >> "$LOG"
				echo -e "\n\e[101;1;97m$ErrorMode_m\e[m\n"
				echo -e "\n\e[101;1;97m$date $ErrorMode_m\e[m\n" >> "$LOG"
				errormode=1
			fi
		else #good answer
			#error mode ---> alert & log
			if [[ $errormode == 1 ]]; then
				aae=$((aae+1)) #count alive after error
				if [ "$aae" == 30 ]; then #30 good ping after error ends error mode
					echo -e "\e[42;1;97m$line\e[m"
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
					echo -e "\n\e[42;1;97m$HostStable_m\e[m\n"
					echo -e "\n\e[42;1;97m$date $HostStable_m\e[m\n" >> "$LOG"
					aae=0; #reset AAE
					errormode=0;
				elif [ "$aae" == 1 ]; then #first good ping after error
					echo -e "\e[42;1;97m$line\e[m"
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
					echo -e "\n\e[42;1;97m$HostUp_m\e[m\n"
					echo -e "\n\e[42;1;97m$date $HostUp_m\e[m\n" >> "$LOG"
				else
					echo -e "\e[42;1;97m$line\e[m"
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
				fi
			else #no error
				echo "$line"
			fi
		fi
		done
	else #default iface
		aae=0 #alive after errors
		ping -O "${ips[$1]}" | while read -r line; do
		echo -e "\n${ips[$1]}: "
		if [[ "$line" =~ "Unreachable" ]] || [[ "$line" =~ "no answer" ]]; then
			if [[ "$errormode" == 1 ]]; then
				echo -e " \e[101;1;97m $Warning_m $line\e[m"
			else
				echo -e "\e[101;1;97m$line\e[m"
				echo -e "\e[101;1;97m$date $line\e[m" >> "$LOG"
				echo -e "\n\e[101;1;97m$ErrorMode_m\e[m\n"
				echo -e "\n\e[101;1;97m$date $ErrorMode_m\e[m\n" >> "$LOG"
				errormode=1
			fi
		else #good answer
			#error mode ---> alert & log
			if [[ "$errormode" == 1 ]]; then
				aae=$((aae+1)) #count alive after error
				if [ "$aae" == 30 ]; then #30 good ping after error ends error mode
					echo -e "\e[42;1;97m$line\e[m"
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
					echo -e "\n\e[42;1;97m$HostStable_m\e[m\n"
					echo -e "\n\e[42;1;97m$date $HostStable_m\e[m\n" >> "$LOG"
					aae=0; #reset AAE
					errormode=0
				elif [ "$aae" == 1 ]; then #first good ping after error
					echo -e "\e[42;1;97m$line\e[m"
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
					echo -e "\n\e[42;1;97m$date $HostUp_m\e[m\n"
					echo -e "\n\e[42;1;97m$date $HostUp_m\e[m\n" >> "$LOG"
				else
					echo -e "\e[42;1;97m$line\e[m"
				fi
			else #no error
				echo "$line"
			fi
		fi
		done
	fi
}
function listening_() { #exit?
	while true; do
		read -rsn1 option
		if [[ "$option" == "" ]] || [[ "$option" == "q" ]]; then
			rm scan
			pkill $$
		fi
	done
}
#########################
#       MAIN            #
#########################
isroot
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
	ping_ip "$mc" &
done
listening_
