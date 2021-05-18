#!/bin/bash
source /var/lib/pmon/general

isRoot

echo -ne "Intalling dependencies...\n";
sleep 1
[[ `which arp-scan` ]] || {
	echo -ne "Installing arp-scan...\r";
	sleep 1;
	apt install arp-scan
}
[[ `which ifconfig` ]] || {
	echo -ne "Installing net-tools...\r";
	sleep 1;
	apt install net-tools
}
echo 'ok'
echo -ne "Making diresctories and moving files..\n";
sleep 1
if [[ -d /var/lib/pmon ]]; then
	echo "It appears that pmon is alredy installed, do you want to continue? (y/n)";
	read yesorno;
	if [[ $yesorno == "y" ]] || [[ $yesorno == "yes" ]]; then
		echo -ne "Removing files...\r"
		rm -r /var/lib/pmon
		rm /usr/bin/pmon
		rm /bin/pmond
		rm /etc/init.d/pmon
		rm /var/log/pmon.err.log
		rm /var/log/pmon.log
		rm -r /etc/pmon
		rm -r /tmp/pmon
	else 
		exit 1;
	fi  
fi
echo -ne "Making directories...\r"
sleep 2
echo -ne "/var/lib/pmon                \r"
sleep 0.5
mkdir /var/lib/pmon
sleep 0.5
echo -ne "/etc/pmon\r"
sleep 0.5
mkdir /etc/pmon
mkdir /tmp/pmon
echo -ne "ok\n"

echo -ne "Copying files...    \r"
sleep 0.5
sleep 0.5
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
echo -ne "Copying triggers...\n" 
cp service/pmond /bin/pmond
cp pmon.sh /usr/bin/pmon
echo "Installed"

