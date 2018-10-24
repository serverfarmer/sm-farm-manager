#!/bin/sh

if [ "$1" = "" ]; then
	echo "usage: $0 <hostname>"
	exit 1
fi

query=$1
shift

server=`/opt/farm/ext/farm-manager/internal/lookup-server.sh $query`

host=`/opt/farm/ext/farm-manager/internal/decode.sh host $server`
port=`/opt/farm/ext/farm-manager/internal/decode.sh port $server`
tag=`/opt/farm/ext/farm-manager/internal/decode.sh tag $server`

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh start $tag
fi

sshkey=`/opt/farm/ext/keys/get-ssh-management-key.sh $host`
ssh -t -i $sshkey -p $port -o StrictHostKeyChecking=no root@$host $@

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh stop $tag
fi
