#!/usr/bin/env bash

################################
#         MESSAGES             #
################################


IpNotFound_m="########## IP NOT FOUND FOR ${1} ##########"
NoIfc_msg="error. No such interface"
InvalidMac_m="mac is invalid!"
ErrorMode_m="WARNING! THE HOST IS DOWN OR REFUSING THE PING STARTING ERROR MODE"
HostStable_m="HOST IS STABLE. ENDING ERROR MODE"
Warning_m="WARNING: "
HostUp_m="HOST IS UP"

usageMsg() {
	echo "	
Usage: pmon [options] [MAC(s)]
		
Run pmon -h or pmon --help to view more information
			";
	exit 2;
}
helpMsg() {
	echo "Usage: pmon [options] [MAC(s)]

Options:
	-I			Interface to use
	-v --verbosity		Verbosity level [0-5]
	--no-screen		Similar to '-v 0'
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
}
nomac_msg() {
	echo "Error: No MAC(s) introduced"
}