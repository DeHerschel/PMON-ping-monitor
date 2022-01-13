#!/usr/bin/env bash

#######################
#   GLOBAL VARIABLES  #
#######################
source messages.sh
LOG="event.log";
DATE="$(date)";
declare -A ips; #Asociative array ips[mac-->IP, mac-->IP,...]

#######################
#      FUNCTIONS      #
#######################

function validmac() { #valid mac?
	echo "$1" | egrep "^^([a-fA-F0-9]{2}:){5}([a-fA-F0-9]{2})$"  > /dev/null
	if [ "$?" == 1 ]; then
			return 1;
	fi
}

function scan() {
	mac="$1";
	ip=$(echo "$scan" | grep "$mac" | awk '{print $1}');
	echo $ip
	ip_comp=$(echo "$scan" | grep "$mac" | awk '{print $1}' | wc -l);
	echo $ip_comp
	echo $scan
	if  [ $ip_comp == 0 ]; then #Not in arp table
		echo -e "\n\n\e[101;1;97m########## IP NOT FOUND FOR $1 ##########\e[0m\n\n";
	else
		ips[$mac]="$ip";
	fi
}
function ping_ip() {
	if [[ "${ips[$1]}" == "" ]]; then #no ip from mac
		return;
	elif [ "$ifc" ]; then #selected iface
		aae=0; #alive after errors
		ping -O "${ips[$1]}" -I "$ifc" | while read -r line; do #ping and read lines
		#no answer ---> eroor mode ---> alert & log
		echo -e "\n${ips[$1]}: ";
		if [[ "$line" =~ "Unreachable" ]] || [[ "$line" =~ "no answer" ]]; then
			if [[ "$errormode" == 1 ]]; then
				echo -e " \e[101;1;97m WARNING: $line\e[m";
			else
				echo -e "\e[101;1;97m$line\e[m";
				echo -e "\e[101;1;97m$date $line\e[m" >> "$LOG";
				echo -e "\n\e[101;1;97mWARNING! THE HOST IS DOWN OR REFUSING THE PING STARTING ERROR MODE\e[m\n";
				echo -e "\n\e[101;1;97m$date WARNING! THE HOST IS DOWN OR REFUSING THE PING STARTING ERROR MODE\e[m\n" >> "$LOG"
				errormode=1;
			fi
		else #good answer
			#error mode ---> alert & log
			if [[ $errormode == 1 ]]; then
				aae=$((aae+1)); #count alive after error
				if [ "$aae" == 30 ]; then #30 good ping after error ends error mode
					echo -e "\e[42;1;97m$line\e[m";
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
					echo -e "\n\e[42;1;97mHOST IS STABLE. ENDING ERROR MODE\e[m\n";
					echo -e "\n\e[42;1;97m$date HOST IS STABLE. ENDING ERROR MODE\e[m\n" >> "$LOG"
					aae=0; #reset AAE
					errormode=0;
				elif [ "$aae" == 1 ]; then #first good ping after error
					echo -e "\e[42;1;97m$line\e[m";
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
					echo -e "\n\e[42;1;97m$date HOST IS UP\e[m\n";
					echo -e "\n\e[42;1;97m$date HOST IS UP\e[m\n" >> "$LOG"
				else
					echo -e "\e[42;1;97m$line\e[m";
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
				fi
			else #no error
				echo "$line";
			fi
		fi
		done &
		pingpids=(${pingpids[@]} $!)
	else #default iface
		aae=0; #alive after errors
		ping -O "${ips[$1]}" | while read -r line; do
		echo -e "\n${ips[$1]}: ";
		if [[ "$line" =~ "Unreachable" ]] || [[ "$line" =~ "no answer" ]]; then
			if [[ "$errormode" == 1 ]]; then
				echo -e " \e[101;1;97m WARNING: $line\e[m";
			else
				echo -e "\e[101;1;97m$line\e[m";
				echo -e "\e[101;1;97m$date $line\e[m" >> "$LOG"
				echo -e "\n\e[101;1;97mWARNING! THE HOST IS DOWN OR REFUSING THE PING STARTING ERROR MODE\e[m\n";
				echo -e "\n\e[101;1;97m$date WARNING! THE HOST IS DOWN OR REFUSING THE PING STARTING ERROR MODE\e[m\n" >> "$LOG"
				errormode=1;
			fi
		else #good answer
			#error mode ---> alert & log
			if [[ "$errormode" == 1 ]]; then
				aae=$((aae+1)) #count alive after error
				if [ "$aae" == 30 ]; then #30 good ping after error ends error mode
					echo -e "\e[42;1;97m$line\e[m";
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
					echo -e "\n\e[42;1;97mHOST IS STABLE. ENDING ERROR MODE\e[m\n";
					echo -e "\n\e[42;1;97m$date HOST IS STABLE. ENDING ERROR MODE\e[m\n" >> "$LOG"
					aae=0; #reset AAE
					errormode=0;
				elif [ "$aae" == 1 ]; then #first good ping after error
					echo -e "\e[42;1;97m$line\e[m";
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
					echo -e "\n\e[42;1;97m$date HOST IS UP\e[m\n";
					echo -e "\n\e[42;1;97m$date HOST IS UP\e[m\n" >> "$LOG"
				else
					echo -e "\e[42;1;97m$line\e[m";
					echo -e "\e[42;1;97m$date $line\e[m" >> "$LOG"
				fi
			else #no error
				echo "$line";
			fi
		fi
		done &
		pingpids=(${pingpids[@]} $!)
	fi
}
function view-log() {
	echo "
	what text editor do you want to use?

	1) Nano/Pico (Default)
	2) Vi
	3) Vim
	4) gedit
	5) emacs

	"
	read -rn1 editor
	case $editor in
		1)
			nano "$LOG"
			;;
		2)
			vi "$LOG"
			;;
		3)
			vim "$LOG"
			;;
		4)
		 	gedit "$LOG"
			;;
		5)
			emacs "$LOG"
			;;
		*)
			nano "$LOG"
			;;
	esac
}
function listening_() { #exit?
	while true; do
		read -rsn1 option;
		if [[ "$option" == "" ]] || [[ "$option" == "q" ]]; then
			kill ${pingpids[@]}
			exit
		elif [[ "$option" == "l" ]]; then
			tmux new-session -d -s pmon
			tmux send-keys "source pmon_functions.sh" C-m
			tmux send-keys "view-log"
			tmux attach-session -t pmon
		fi
	done
}
