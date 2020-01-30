#!/bin/bash
. /opt/farm/ext/net-utils/functions

if [ "$1" = "" ]; then
	echo "usage: $0 <hostname[:port]> [username] [key-passphrase]"
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

if [ "$2" != "" ]; then
	user=$2
else
	user=root
fi

SSH=/opt/farm/ext/binary-ssh-client/wrapper/ssh

newkey=`/opt/farm/ext/keys/get-ssh-dedicated-key.sh $host $user`
admkey=`/opt/farm/ext/keys/get-ssh-management-key.sh $host`

if ! [[ $user =~ ^[a-z0-9]+$ ]]; then
	echo "error: parameter $2 not conforming username format"
	exit 1
elif [ -f $newkey ]; then
	echo "error: key $newkey already exists"
	exit 1
fi

entry=`$SSH -i $admkey -p $port -o StrictHostKeyChecking=no -o PasswordAuthentication=no root@$host getent passwd $user 2>/dev/null`

if [[ "$entry" = "" ]]; then
	echo "error: host $server denied access, or user $user not found"
	exit 1
fi

ssh-keygen -f $newkey -C $user@$host -N "$3"
pubkey=`cat $newkey.pub`
home=`echo "$entry" |cut -d: -f 6`

$SSH -i $admkey -p $port root@$host "mkdir -p $home/.ssh"
$SSH -i $admkey -p $port root@$host "echo \"$pubkey\" >>$home/.ssh/authorized_keys"
