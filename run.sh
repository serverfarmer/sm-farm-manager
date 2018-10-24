#!/bin/sh

if [ "$2" = "" ]; then
	echo "usage: $0 <hostname> <script> [argument] [...]"
	exit 1
elif [ ! -f $2 ]; then
	echo "error: file $2 not found"
	exit 1
fi

query=$1
script="`realpath $2`"
shift
shift

server=`/opt/farm/ext/farm-manager/internal/lookup-server.sh $query`

host=`/opt/farm/ext/farm-manager/internal/decode.sh host $server`
port=`/opt/farm/ext/farm-manager/internal/decode.sh port $server`
tag=`/opt/farm/ext/farm-manager/internal/decode.sh tag $server`

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh start $tag
fi

sshkey=`/opt/farm/ext/keys/get-ssh-management-key.sh $host`
remote="`dirname $script`"

ssh -i $sshkey -p $port -o StrictHostKeyChecking=no root@$host mkdir -p $remote

if [[ $? = 0 ]]; then
	scp -i $sshkey -P $port $script root@$host:$remote
	ssh -i $sshkey -p $port -t root@$host "sh -c '$script $@'"
fi

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh stop $tag
fi
