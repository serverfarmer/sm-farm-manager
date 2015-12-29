#!/bin/bash
. /opt/farm/scripts/functions.custom

path="/etc/local/.config"

if [ "$1" = "" ]; then
	echo "usage: $0 <hostname>"
	exit 1
elif ! [[ $1 =~ ^[a-z0-9.-]+[.][a-z0-9]+$ ]]; then
	echo "error: parameter $1 not conforming hostname format"
	exit 1
elif [ "`getent hosts $1`" = "" ]; then
	echo "error: host $1 not found"
	exit 1
elif [ "`cat $path/*.hosts |grep \"^$1$\"`" != "" ]; then
	echo "error: host $1 already added"
	exit 1
fi

sshkey=`ssh_management_key_storage_filename $1`
ssh -i $sshkey -o StrictHostKeyChecking=no -o PasswordAuthentication=no root@$1 uptime >/dev/null 2>/dev/null

if [[ $? != 0 ]]; then
	echo "error: host $1 denied access"
	exit 1
fi

if [ -x /opt/sf-backup-collector/add-backup-host.sh ]; then
	/opt/sf-backup-collector/add-backup-host.sh $1
fi

hwtype=`ssh -i $sshkey root@$1 /opt/farm/scripts/config/detect-hardware-type.sh`
openvz=`ssh -i $sshkey root@$1 "cat /proc/vz/version 2>/dev/null"`
netmgr=`ssh -i $sshkey root@$1 "ls /etc/NetworkManager 2>/dev/null"`

if [ "$netmgr" != "" ]; then
	echo $1 >>"$path/workstation.hosts"
elif [ $hwtype = "physical" ]; then
	echo $1 >>"$path/physical.hosts"
elif [ $hwtype = "guest" ]; then
	echo $1 >>"$path/virtual.hosts"
fi

if [ "$openvz" != "" ]; then
	echo $1 >>"$path/openvz.hosts"
fi

# TODO: implement checking, if added host runs also Xen / LXC / Docker containers
