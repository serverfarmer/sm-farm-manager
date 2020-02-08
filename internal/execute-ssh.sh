#!/bin/sh

host=$1
port=$2
sshkey=$3
timeout=$4
command=$5
comment=$6
SSH=/opt/farm/ext/binary-ssh-client/wrapper/ssh

echo
echo "####### executing \"$command\" on $comment $host"

$SSH -t -i $sshkey -p $port -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout root@$host "$command"
