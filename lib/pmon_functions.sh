#!/bin/bash

source lib/messages.sh;
unset HOST;
unset PTIME;
unset PICMP;
unset PTTL;
unset LOG;
unset ERRLOG;
unset DATE;

LOG="/var/log/pmon.log";
DATE="$(date)";
ERRLOG="/var/log/pmon.err.log";

#######################
#      FUNCTIONS      #
#######################

function isdMac() { #valid mac?
	echo "$1" | egrep "^^([a-fA-F0-9]{2}:){5}([a-fA-F0-9]{2})$"  > /dev/null
	[ "$?" == 0 ] || return 1;
}
function isIp() {
	echo "$1" | egrep "^^(1-255].){3}([1-255])$"  > /dev/null
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
function getStats() {
	local ping=$1;
	local ping=($ping)
	if [[ TARGET  == 'IP' ]]; then
		PTIME=${ping[6]:5};
		PTTL=${ping[5]:4};
		PICMP=${ping[4]:9};
	else
		PTIME=${ping[7]:5};
		PTTL=${ping[6]:4};
		PICMP=${ping[5]:9};
	fi
}
function pingHost() { #ARGS: "mac"/"host" MAC/HOST IFC
	local aae=0; #alive after errors
	local errormode=0;
	[[ $IFC ]] && local ifc="-I $IFC"; 
	if [[ "$1" == "mac" ]]; then
		TARGET='IP';
		HOST=$(macHaveIp "$2") || return;
	elif [[ "$1" == "host" ]]; then
		if ! isIp; then
			TARGET='DNS';
		else 
			TARGET='IP';
		fi
		HOST="$2";
	fi
	local isfirst=1 #use for display only in the second round of the loop
	ping -O $HOST $ifc | while read -r line; do #ping and read lines
		echo -e "${HOST}: ";
		if [[ "$line" =~ "Unreachable" ]] || [[ "$line" =~ "no answer" ]]; then
		#no answer ---> eroor mode ---> alert & log
			[ "$errormode" -eq 1 ] && {	
				echo -e " \e[101;1;97m WARNING: ${line}\e[m\n";
				continue;
			}
			hostdownMsg && hostdownMsg >> "$LOG";
			echo -e "${line}\n" && echo -e "${DATE}: ${line}" >> "$LOG";
			errormode=1;
		else #good answer
			getStats "$line"
			[ $isfirst -eq 1 ] && {
				echo -e "$line\n"
				isfirst=0;
				continue;
			} 
			statsMsg
			LAST_PICMP=$PICMP;
			[ "$errormode" -eq 0 ] && {
				echo -e "$line\n";
				continue;
			}
			let aae=aae+1; #count aae
			[ "$aae" -eq 1 ] && { #first good ping after error
				echo -e "\n${DATE}: HOST IS UP\n" && echo -e "${DATE} HOST IS UP" >> "$LOG";
				echo -e "${line}\n" && echo -e "${DATE}: ${line}" >> "$LOG";
				continue;
			}
			[ "$aae" -eq 30 ] && { #30 good ping after error ends error mode
				hoststableMsg && hoststable_msg >> "$LOG";
				echo -e "${line}\n" && echo -e "${DATE}: ${line}" >> "$LOG";
				aae=0; #reset AAE
				errormode=0;
				continue;
			}
			echo -e "${line}\n";
		fi
	done &
	pingpids=(${pingpids[@]} $!);
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
