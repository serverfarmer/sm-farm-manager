#!/bin/sh

host=$1
port=$2
sshkey=$3
command=$4
comment=$5

echo
echo "####### executing \"$command\" on $comment $host"

ssh -t -i $sshkey -p $port -o StrictHostKeyChecking=no root@$host "$command"
