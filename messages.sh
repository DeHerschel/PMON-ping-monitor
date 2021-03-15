#!/usr/bin/env bash

################################
#         MESSAGES             #
################################

NoRoot_m="######ERROR!!! NOT ROOT. EXECUTE AS ROOT######"
IpNotFound_m="########## IP NOT FOUND FOR $1 ##########"
NoMac_m="NO MAC(s) INTRODUCED
exiting"
NoIfc_m=" ######ERROR!!! NO INTERFACE FOUND WITH NAME $ifc ######"
InvalidMac_m="\n\n\e[101;1;97mMAC $((c+1)) IS INVALID!!!\e[0m\n\n"
ErrorMode_m="WARNING! THE HOST IS DOWN OR REFUSING THE PING STARTING ERROR MODE"
HostStable_m="HOST IS STABLE. ENDING ERROR MODE"
Warning_m="WARNING: "
HostUp_m="HOST IS UP"
