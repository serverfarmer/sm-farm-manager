#!/bin/bash
. /opt/farm/scripts/functions.custom

if [ "$1" = "" ]; then
	echo "usage: $0 <hostname>"
	exit 1
fi

path="/etc/local/.farm"
orig=$1
query=$1
shift

server=`grep -h "^$query$" $path/physical.hosts $path/virtual.hosts $path/lxc.hosts $path/ec2.hosts $path/workstation.hosts $path/problematic.hosts |head -1`
if [ "$server" = "" ]; then

	if [ "`getent hosts \"$query\"`" != "" ]; then
		query="^$query[.:]"
	fi

	# TODO: sort by the longest match, instead of the longest entry
	server=`grep -h "$query" $path/physical.hosts $path/virtual.hosts $path/lxc.hosts $path/ec2.hosts $path/workstation.hosts $path/problematic.hosts |awk '{ print length($0) " " $0; }' |sort -rn |cut -d ' ' -f 2- |head -1`
fi

if [ "$server" = "" ]; then
	server=$orig
fi

if [ -z "${server##*:*}" ]; then
	host="${server%:*}"
	port="${server##*:}"
else
	host=$server
	port=22
fi

sshkey="`ssh_management_key_storage_filename $host`"
ssh -t -i $sshkey -p $port -o StrictHostKeyChecking=no root@$host $@
