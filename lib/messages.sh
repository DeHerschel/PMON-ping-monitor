#!/bin/bash

################################
#         MESSAGES             #
################################

NoIfc_msg() {
	echo "error. No such interface";
}
InvalidMac_m() {
	echo "mac ${1} is invalid!";
}
hostdownMsg() {
	echo "WARNING! THE HOST IS DOWN OR REFUSING THE PING STARTING ERROR MODE";
}
hoststable_msg() {
	echo "HOST IS STABLE. ENDING ERROR MODE";
}
ipNotFoundMsg() {
	echo -e "########## IP NOT FOUND FOR MAC ${1} ##########\n";
}
usageMsg() {
	echo "	
Usage: pmon [options] [MAC(s)] OR pmon [options] -t [HOST]
Run pmon -h or pmon --help to view more information
			";
	exit 2;
}
helpMsg() {
	echo "Usage: pmon [options] [MAC(s)] OR pmon [options] -t [HOST]
Options:
	-I			Interface to use
	-v --verbosity		Verbosity level [0-5]
	-h --help		Show this message
	";
	exit 0;
}
norootMsg() {
	echo "Error! Not root.";
	exit 2; 
}
verbosityError() {
	echo "Error: verbosity mode need a number between 0 and 5";
	usageMsg;
}
nomac_msg() {
	echo "Error: No MAC(s) introduced";
}
statsMsg() {
	local problems=0;
	local state='NORMAL';
	if [[ ${PTIME::1} -lt 20 ]]; then
		state='GOOD';
	elif [[ $PTIME -gt 100 ]]; then
		state='BAD';
	fi
	[[ $(($PICMP-1)) -eq $LAST_PICMP ]] || let problems=$problems+1
	echo "TTL=$PTTL		ICMP=$PICMP		TIME=$PTIME
PING STATE: $state 		PROBLEMS: $problems"
}		