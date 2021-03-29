#!/usr/bin/env bash
source messages.sh
unset HOST
LOG="/var/log/pmon.log";
DATE="$(date)";
ERRLOG="/var/log/pmon.err.log"

#######################
#      FUNCTIONS      #
#######################

function validMac() { #valid mac?
	echo "$1" | egrep "^^([a-fA-F0-9]{2}:){5}([a-fA-F0-9]{2})$"  > /dev/null
	[ "$?" == 0 ] || return 1;
}
function macHaveIp() {
	local ip=$(echo "$scan" | grep "$1" | awk '{print $1}');
	local ip_comp=$(echo "$scan" | grep "$1" | awk '{print $1}' | wc -l);
	if  [ $ip_comp == 0 ]; then #Not in arp table
		ipNotFoundMsg && ipNotFoundMsg >> $ERRLOG;
		return 2;
	fi
	echo $ip;
}
function pingHost() { #ARGS: "mac"/"host" MAC/HOST IFC
	local aae=0; #alive after errors
	local errormode=0;
	[[ $IFC ]] && local ifc="-I $IFC"; 
	if [[ "$1" == "mac" ]]; then
		HOST=$(macHaveIp "$2") || return;
	elif [[ "$1" == "host" ]]; then
		HOST="$2";
	fi
	ping -O $HOST $ifc | while read -r line; do #ping and read lines
		echo -e "${HOST}: ";
		if [[ "$line" =~ "Unreachable" ]] || [[ "$line" =~ "no answer" ]]; then
		#no answer ---> eroor mode ---> alert & log
			[ "$errormode" -eq 1 ] && {	
				echo -e " \e[101;1;97m WARNING: $line\e[m\n";
				continue;
			}
			echo -e "\n\e[101;1;97m${hostdown_msg}\e[m\n" && echo -e "${DATE}: ${hostdown_msg}" >> "$LOG";
			echo -e "\e[101;1;97m$line\e[m\n" && echo -e "${DATE}: ${line}" >> "$LOG";
			errormode=1;
		else #good answer
			[ "$errormode" -eq 0 ] && {
				echo -e "$line\n";
				continue;
			}
			let aae=aae+1; #count aae
			[ "$aae" -eq 1 ] && { #first good ping after error
				echo -e "\n\e[42;1;97m${DATE}: HOST IS UP\e[m\n" && echo -e "${DATE} HOST IS UP" >> "$LOG";
				echo -e "\e[42;1;97m${line}\e[m\n" && echo -e "${DATE}: ${line}" >> "$LOG";
				continue;
			}
			[ "$aae" -eq 30 ] && { #30 good ping after error ends error mode
				echo -e "\n\e[42;1;97m${hoststable_msg}\e[m\n" && echo -e "${DATE}: ${hoststable_msg}" >> "$LOG";
				echo -e "\e[42;1;97m${line}\e[m\n" && echo -e "${DATE}: ${line}" >> "$LOG";
				aae=0; #reset AAE
				errormode=0;
				continue;
			}
			echo -e "\e[42;1;97m${line}\e[m\n";
		fi
	done &
	pingpids=(${pingpids[@]} $!)
}
function viewLog() {
	echo "
what text editor do you want to use?

1) nano (Default)
3) Vim
5) emacs
4) gedit
*) nano
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
function keyEventListener() {
	while true; do
		read -rsn1 option;
		if [[ "$option" == "" ]] || [[ "$option" == "q" ]]; then
			kill "${pingpids[@]}";
			exit 0;
		elif [[ "$option" == "l" ]]; then
			tmux new-session -d -s pmon
			tmux send-keys "source pmon_functions.sh" C-m
			tmux send-keys "vieLog"
			tmux attach-session -t pmon
		fi
	done
}