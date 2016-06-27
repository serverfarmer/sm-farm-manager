#!/bin/bash
# This script provides easy renaming functionality for Amazon EC2 instances
# after public hostname change (due to eg. instance temporary shutdown, AWS
# zone failure, or migrating to Elastic IP).
#
# Tomasz Klim, Jun 2016

path="/etc/local/.farm"
remote="/srv/mounts/backup/remote"

if [ "$2" = "" ]; then
	echo "usage: $0 <old-hostname> <new-hostname>"
	exit 1
elif ! [[ $1 =~ ^[a-z0-9.-]+[.][a-z0-9]+$ ]]; then
	echo "error: parameter $1 not conforming hostname format"
	exit 1
elif ! [[ $2 =~ ^[a-z0-9.-]+[.][a-z0-9]+$ ]]; then
	echo "error: parameter $2 not conforming hostname format"
	exit 1
elif [ "`getent hosts $1`" = "" ] && [ "`getent hosts $2`" = "" ]; then
	echo "error: both hostnames not found"
	exit 1
elif [ "`cat $path/*.hosts |grep \"^$1$\"`" = "" ]; then
	echo "error: host $1 not in farm"
	exit 1
fi


for dbfile in `grep -l $1 $path/*.hosts`; do
	sed -i -e "s/$1/$2/" $dbfile
done

for oldkey in `ls /etc/local/.ssh/key-*@$1 2>/dev/null`; do
	newkey=`echo $oldkey |sed s/$1/$2/g`
	mv $oldkey $newkey
	mv $oldkey.pub $newkey.pub
done

if [ -d $remote/$1 ]; then
	mv $remote/$1 $remote/$2
fi

ssh -i /etc/local/.ssh/key-root@$2 -o StrictHostKeyChecking=no -o PasswordAuthentication=no root@$2 uptime >/dev/null 2>/dev/null
