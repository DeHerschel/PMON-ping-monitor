#!/bin/bash
service pmon stop
killall ping
echo -ne "/etc/pmon/pmon.conf\r"
cp service/pmon.conf /etc/pmon/pmon.conf
sleep 0.5
echo -ne "/etc/pmon/hosts.list\r"
cp service/hosts.list /etc/pmon/hosts.list
sleep 0.5
echo -ne "/etc/init.d/pmon            \r"
cp service/pmon-service /etc/init.d/pmon

sleep 0.5
echo -ne "/var/lib/pmon/.....\r"
sleep 0.5
echo -ne "/var/lib/pmon/.....\r"
sleep 0.5
echo -ne "/var/lib/pmon/.....\r"
sleep 0.5
echo -ne "/var/lib/pmon/.....\r"
sleep 0.5
echo -ne "/var/lib/pmon/.....\r"
sleep 0.5
echo -ne "/var/lib/pmon/.....\r"
cp lib/* /var/lib/pmon/
echo -ne "Copying triggers...\r" 
cp service/pmond /bin/pmond
cp pmon.sh /usr/bin/pmon
echo "Dev OK                      "
