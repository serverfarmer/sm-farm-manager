#!/bin/sh

if [ "$3" = "" ]; then
	echo "usage: $0 <mode> <server> <command> [comment]"
	exit 1
fi

mode=$1
server=$2
command=$3
comment=$4

host=`/opt/farm/ext/farm-manager/internal/decode.sh host $server`
port=`/opt/farm/ext/farm-manager/internal/decode.sh port $server`
tag=`/opt/farm/ext/farm-manager/internal/decode.sh tag $server`

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh start $tag
fi

sshkey=`/opt/farm/ext/keys/get-ssh-management-key.sh $host`
/opt/farm/ext/farm-manager/internal/execute-$mode.sh $host $port $sshkey "$command" "$comment"

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh stop $tag
fi
