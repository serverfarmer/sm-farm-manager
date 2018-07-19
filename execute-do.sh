#!/bin/bash
. /opt/farm/scripts/functions.custom
. /opt/farm/ext/keys/functions

exec_ssh() {
	host=$1
	port=$2
	sshkey=$3
	command=$4
	comment=$5

	echo
	echo "####### executing \"$command\" on $comment $host"
	ssh -t -i $sshkey -p $port -o StrictHostKeyChecking=no root@$host "$command"
}

exec_openvz() {
	host=$1
	port=$2
	sshkey=$3
	command=$4

	containers="`ssh -i $sshkey -p $port root@$host \"/usr/sbin/vzlist -Ho ctid\"`"

	for ID in $containers; do
		cthost="`ssh -i $sshkey -p $port root@$host \"/usr/sbin/vzlist -Ho hostname $ID\"`"
		echo
		echo "####### executing \"$command\" on container $ID [$cthost] at server $hostr"
		ssh -t -i $sshkey -p $port root@$host "/usr/sbin/vzctl exec $ID \"TERM=vt100 $command\""
	done
}

exec_docker() {
	host=$1
	port=$2
	sshkey=$3
	command=$4

	containers="`ssh -i $sshkey -p $port root@$host \"docker ps -q\"`"

	for ID in $containers; do
		echo
		echo "####### executing \"$command\" on container $ID at server $host"
		ssh -t -i $sshkey -p $port root@$host "docker exec -ti $ID $command"
	done
}


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

sshkey="`ssh_management_key_storage_filename $host`"
exec_$mode $host $port $sshkey "$command" "$comment"

if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "$tag" != "" ]; then
	/etc/local/hooks/ssh-accounting.sh stop $tag
fi
