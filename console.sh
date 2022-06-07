#!/bin/sh

if [ "$1" = "" ]; then
	echo "usage: $0 <hostname>"
	exit 1
fi

query=$1
shift

# TODO: if $query contains login@ part, extract it and use below instead of fixed root user

server=`/opt/farm/mgr/farm-manager/internal/lookup-server.sh $query`

host=`/opt/farm/mgr/farm-manager/internal/decode.sh host $server`
port=`/opt/farm/mgr/farm-manager/internal/decode.sh port $server`
tag=`/opt/farm/mgr/farm-manager/internal/decode.sh tag $server`

if [ -x ~/.serverfarmer/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	~/.serverfarmer/hooks/ssh-accounting.sh start $tag
fi

sshkey=`/opt/farm/ext/keys/get-ssh-management-key.sh $host`
SSH=/opt/farm/ext/binary-ssh-client/wrapper/ssh
$SSH -t -i $sshkey -p $port -o StrictHostKeyChecking=no root@$host $@

if [ -x ~/.serverfarmer/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	~/.serverfarmer/hooks/ssh-accounting.sh stop $tag
fi
