#!/bin/sh

host=$1
port=$2
sshkey=$3
command=$5
SSH=/opt/farm/ext/binary-ssh-client/wrapper/ssh

echo
echo "####### fetching OpenVZ containers list from server $host"

containers="`$SSH -i $sshkey -p $port root@$host \"/usr/sbin/vzlist -Ho ctid\"`"

for ID in $containers; do
	cthost="`$SSH -i $sshkey -p $port root@$host \"/usr/sbin/vzlist -Ho hostname $ID\"`"
	echo
	echo "####### executing \"$command\" on container $ID [$cthost] at server $host"
	$SSH -t -i $sshkey -p $port root@$host "/usr/sbin/vzctl exec $ID \"TERM=vt100 $command\""
done
