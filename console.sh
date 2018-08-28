#!/bin/bash

if [ "$1" = "" ]; then
	echo "usage: $0 <hostname>"
	exit 1
fi

query=$1
shift

server=`/opt/farm/ext/farm-manager/internal/lookup-server.sh $query`

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
ssh -t -i $sshkey -p $port -o StrictHostKeyChecking=no root@$host $@

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh stop $tag
fi
