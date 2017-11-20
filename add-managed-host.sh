#!/bin/bash
. /opt/farm/scripts/functions.net
. /opt/farm/scripts/functions.custom
. /opt/farm/scripts/functions.keys

path="/etc/local/.farm"

if [ "$1" = "" ]; then
	echo "usage: $0 <hostname[:port]>"
	exit 1
elif [ "`resolve_host $1`" = "" ]; then
	echo "error: parameter $1 not conforming hostname format, or given hostname is invalid"
	exit 1
fi

server=$1
if [ -z "${server##*:*}" ]; then
	host="${server%:*}"
	port="${server##*:}"
else
	host=$server
	port=22
fi

if [ "`cat $path/*.hosts |grep \"^$host$\"`" != "" ]; then
	echo "error: host $host already added"
	exit 1
fi

sshkey=`ssh_management_key_storage_filename $host`
ssh -i $sshkey -p $port -o StrictHostKeyChecking=no -o PasswordAuthentication=no root@$host uptime >/dev/null 2>/dev/null

if [[ $? != 0 ]]; then
	echo "error: host $server denied access"
	exit 1
fi

hwtype=`ssh -i $sshkey -p $port root@$host /opt/farm/ext/system/detect-hardware-type.sh`
docker=`ssh -i $sshkey -p $port root@$host "which docker 2>/dev/null"`
openvz=`ssh -i $sshkey -p $port root@$host "cat /proc/vz/version 2>/dev/null"`
netmgr=`ssh -i $sshkey -p $port root@$host "cat /etc/X11/xinit/xinitrc 2>/dev/null"`
cloud=`ssh -i $sshkey -p $port root@$host "cat /etc/cloud/build.info 2>/dev/null"`

if [ "$netmgr" != "" ]; then
	echo $server >>"$path/workstation.hosts"
elif [ $hwtype = "physical" ]; then
	echo $server >>"$path/physical.hosts"
elif [ $hwtype = "lxc" ]; then
	echo $server >>"$path/lxc.hosts"
elif [ "$cloud" != "" ]; then
	echo $server >>"$path/cloud.hosts"
elif [ $hwtype = "guest" ]; then
	echo $server >>"$path/virtual.hosts"
fi

if [ "$openvz" != "" ]; then
	echo $server >>"$path/openvz.hosts"
fi

if [ "$docker" != "" ]; then
	echo $server >>"$path/docker.hosts"
fi

/opt/farm/ext/farm-manager/add-dedicated-key.sh $server root

if [ $hwtype != "container" ] && [ $hwtype != "lxc" ]; then
	/opt/farm/ext/farm-manager/add-dedicated-key.sh $server backup

	if [ -x /opt/farm/ext/backup-collector/add-backup-host.sh ]; then
		/opt/farm/ext/backup-collector/add-backup-host.sh $server
	fi
fi
