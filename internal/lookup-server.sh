#!/bin/sh

if [ "$1" = "" ]; then
	echo "usage: $0 <query>"
	exit 1
fi

path=~/.farm
orig=$1
query=$1

server=`grep -h "^$query$" $path/physical.hosts $path/virtual.hosts $path/lxc.hosts $path/container.hosts $path/cloud.hosts $path/workstation.hosts $path/problematic.hosts |grep -v ^# |head -1`
if [ "$server" = "" ]; then

	if [ "`getent hosts \"$query\"`" != "" ]; then
		query="^$query[.:]"
	fi

	# TODO: sort by the longest match, instead of the longest entry
	server=`grep -h "$query" $path/physical.hosts $path/virtual.hosts $path/lxc.hosts $path/container.hosts $path/cloud.hosts $path/workstation.hosts $path/problematic.hosts |grep -v ^# |awk '{ print length($0) " " $0; }' |sort -rn |cut -d ' ' -f 2- |head -1`
fi

if [ "$server" = "" ]; then
	server=$orig
fi

echo $server
