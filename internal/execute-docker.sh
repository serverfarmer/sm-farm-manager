#!/bin/sh

host=$1
port=$2
sshkey=$3
command=$5

echo
echo "####### fetching Docker containers list from server $host"

containers="`ssh -i $sshkey -p $port root@$host \"docker ps -q\"`"

for ID in $containers; do
	echo
	echo "####### executing \"$command\" on container $ID at server $host"
	ssh -t -i $sshkey -p $port root@$host "docker exec -ti $ID $command"
done
