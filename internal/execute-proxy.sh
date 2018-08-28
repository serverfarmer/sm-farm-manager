#!/bin/bash

if [ "$3" = "" ]; then
	echo "usage: $0 <mode> <server> <command> [comment]"
	exit 1
fi

mode=$1
server=$2
command=$3
comment=$4

if [[ $server =~ ^[a-z0-9.-]+$ ]]; then
	server="$server::"
elif [[ $server =~ ^[a-z0-9.-]+[:][0-9]+$ ]]; then
	server="$server:"
fi

host=$(echo $server |cut -d: -f1)
port=$(echo $server |cut -d: -f2)
tag=$(echo $server |cut -d: -f3)

if [ "$port" = "" ]; then
	port=22
fi

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh start $tag
fi

sshkey=`/opt/farm/ext/keys/get-ssh-management-key.sh $host`
/opt/farm/ext/farm-manager/internal/execute-$mode.sh $host $port $sshkey "$command" "$comment"

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh stop $tag
fi
