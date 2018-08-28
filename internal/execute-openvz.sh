#!/bin/sh

host=$1
port=$2
sshkey=$3
command=$4

echo
echo "####### fetching OpenVZ containers list from server $host"

containers="`ssh -i $sshkey -p $port root@$host \"/usr/sbin/vzlist -Ho ctid\"`"

for ID in $containers; do
	cthost="`ssh -i $sshkey -p $port root@$host \"/usr/sbin/vzlist -Ho hostname $ID\"`"
	echo
	echo "####### executing \"$command\" on container $ID [$cthost] at server $host"
	ssh -t -i $sshkey -p $port root@$host "/usr/sbin/vzctl exec $ID \"TERM=vt100 $command\""
done
