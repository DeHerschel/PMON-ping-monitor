#!/bin/bash
source ./lib/pinghost
source ./lib/messages.sh

unset HOST;
unset PTIME;
unset PICMP;
unset PTTL;
unset LOG;
unset ERRLOG;
unset DATE;
unset ERRORMODE;

LOG="/var/log/pmon.log";
DATE="$(date)";
ERRLOG="/var/log/pmon.err.log";
ERRORMODE=0;
#######################
#      FUNCTIONS      #
#######################

function isdMac() { #valid mac?
	echo "$1" | egrep "^^([a-fA-F0-9]{2}:){5}([a-fA-F0-9]{2})$"  > /dev/null
	[ "$?" == 0 ] || return 1;
}
function isIp() { 
	echo $1 | egrep "^^([1-9].){3}([1-9])$"  > /dev/null
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