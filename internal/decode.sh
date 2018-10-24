#!/bin/bash

if [ "$2" = "" ]; then
	echo "usage: $0 <field> <entry>"
	exit 1
elif [ "$1" != "host" ] && [ "$1" != "port" ] && [ "$1" != "tag" ]; then
	echo "error: invalid field \"$1\""
	exit 1
fi

field=$1
server=$2

if [[ $server =~ ^[a-z0-9.-]+$ ]]; then
	server="$server::"
elif [[ $server =~ ^[a-z0-9.-]+[:][0-9]+$ ]]; then
	server="$server:"
fi

if [ "$1" = "host" ]; then
	echo $server |cut -d: -f1
elif [ "$1" = "tag" ]; then
	echo $server |cut -d: -f3
else
	port=`echo $server |cut -d: -f2`

	if [ "$port" = "" ]; then
		port=22
	fi

	echo $port
fi
