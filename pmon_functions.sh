#!/usr/bin/env bash

#######################
#   GLOBAL VARIABLES  #
#######################

source messages.sh
declare -A ips; #Asociative array ips[mac-->IP, mac-->IP,...]
LOG="event.log";
DATE="$(date)";

#######################
#      FUNCTIONS      #
#######################

function validMac() { #valid mac?
	echo "$1" | egrep "^^([a-fA-F0-9]{2}:){5}([a-fA-F0-9]{2})$"  > /dev/null
	if [ "$?" == 1 ]; then
			return 1;
	fi
}
function macHaveIp() {
	mac="$1";
	ip=$(echo "$scan" | grep "$mac" | awk '{print $1}');
	ip_comp=$(echo "$scan" | grep "$mac" | awk '{print $1}' | wc -l);
	if  [ $ip_comp == 0 ]; then #Not in arp table
		ipNotFoundMsg;
		return 2;
	fi
	ips[$mac]="$ip";
}
function pingIp() {
	macHaveIp $1 || return;
	if [ "$ifc" ]; then #selected iface
		aae=0; #alive after errors
		ping -O "${ips[$1]}" -I "$ifc" | while read -r line; do #ping and read lines
			#no answer ---> eroor mode ---> alert & log
			echo -e "\n${ips[$1]}: ";
			if [[ "$line" =~ "Unreachable" ]] || [[ "$line" =~ "no answer" ]]; then
				if [[ "$errormode" == 1 ]]; then
					echo -e " \e[101;1;97m WARNING: $line\e[m";
				else
					echo -e "\e[101;1;97m$line\e[m" && echo -e "${DATE}: ${line}" >> "$LOG";
					echo -e "\n\e[101;1;97m${hostdown_msg}\e[m\n" && echo -e "${DATE}: ${hostdown_msg}" >> "$LOG";
					errormode=1;
				fi
			else #good answer
				#error mode ---> alert & log
				if [[ $errormode == 1 ]]; then
					let aae=aae+1; #count aae
					if [ "$aae" == 30 ]; then #30 good ping after error ends error mode
						echo -e "\e[42;1;97m${line}\e[m" && echo -e "${DATE}: ${line}" >> "$LOG";
						echo -e "\n\e[42;1;97m${hoststable_msg}\e[m\n" && echo -e "${DATE}: ${hoststable_msg}" >> "$LOG";
						aae=0; #reset AAE
						errormode=0;
					elif [ "$aae" == 1 ]; then #first good ping after error
						echo -e "\e[42;1;97m${line}\e[m" && echo -e "${DATE}: ${line}" >> "$LOG";
						echo -e "\n\e[42;1;97m${DATE} HOST IS UP\e[m\n" && echo -e "${DATE} HOST IS UP" >> "$LOG"
					else
						echo -e "\e[42;1;97m${line}\e[m";
					fi
				else #no error
					echo "$line";
				fi
			fi
		done &
		pingpids=(${pingpids[@]} $!)
	else #default iface
		aae=0; #alive after errors
		ping -O "${ips[$1]}" | while read -r line; do #ping and read lines
			#no answer ---> eroor mode ---> alert & log
			echo -e "\n${ips[$1]}: ";
			if [[ "$line" =~ "Unreachable" ]] || [[ "$line" =~ "no answer" ]]; then
				if [[ "$errormode" == 1 ]]; then
					echo -e " \e[101;1;97m WARNING: $line\e[m";
				else
					echo -e "\e[101;1;97m$line\e[m" && echo -e "${DATE}: ${line}" >> "$LOG";
					echo -e "\n\e[101;1;97m${hostdown_msg}\e[m\n" && echo -e "${DATE}: ${hostdown_msg}" >> "$LOG";
					errormode=1;
				fi
			else #good answer
				#error mode ---> alert & log
				if [[ $errormode == 1 ]]; then
					let aae=aae+1; #count aae
					if [ "$aae" == 30 ]; then #30 good ping after error ends error mode
						echo -e "\e[42;1;97m${line}\e[m" && echo -e "${DATE}: ${line}" >> "$LOG";
						echo -e "\n\e[42;1;97m${hoststable_msg}\e[m\n" && echo -e "${DATE}: ${hoststable_msg}" >> "$LOG";
						aae=0; #reset AAE
						errormode=0;
					elif [ "$aae" == 1 ]; then #first good ping after error
						echo -e "\e[42;1;97m${line}\e[m" && echo -e "${DATE}: ${line}" >> "$LOG";
						echo -e "\n\e[42;1;97m${DATE} HOST IS UP\e[m\n" && echo -e "${DATE} HOST IS UP" >> "$LOG"
					else
						echo -e "\e[42;1;97m${line}\e[m";
					fi
				else #no error
					echo "$line";
				fi
			fi
		done &
		pingpids=(${pingpids[@]} $!)
	fi
	listening_
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
			nano "$LOG";;
		2)
			vi "$LOG";;
		3)
			vim "$LOG";;
		4)
		 	gedit "$LOG";;
		5)
			emacs "$LOG";;
		*)
			nano "$LOG";;
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
