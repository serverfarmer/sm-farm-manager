#!/bin/bash
. /opt/farm/scripts/functions.uid
. /opt/farm/scripts/functions.custom
# create IMAP/fetchmail account:
# - first on local management server (to preserve UID)
# - then on specified mail server (sf-imap-server extension required)
# - last on specified backup server
# Tomasz Klim, 2014-2016


MINUID=1400
MAXUID=1599


if [ "$2" = "" ]; then
	echo "usage: $0 <user> <mail-server[:port]> [backup-server[:port]]"
	exit 1
elif ! [[ $1 =~ ^[a-z0-9]+$ ]]; then
	echo "error: parameter 1 not conforming user name format"
	exit 1
elif ! [[ $2 =~ ^[a-z0-9.-]+[.][a-z0-9]+([:][0-9]+)?$ ]]; then
	echo "error: parameter 2 not conforming host name format"
	exit 1
elif [ -d /srv/imap/$1 ]; then
	echo "error: user $1 exists"
	exit 1
elif [ "`getent hosts $2`" = "" ]; then
	echo "error: host $2 not found"
	exit 1
fi

uid=`get_free_uid $MINUID $MAXUID`

if [ $uid -lt 0 ]; then
	echo "error: no free UIDs"
	exit 1
fi

rserver=$2
if [ -z "${rserver##*:*}" ]; then
	rhost="${rserver%:*}"
	rport="${rserver##*:}"
else
	rhost=$rserver
	rport=22
fi

if [ "$3" != "" ] && [ "$3" != "$2" ]; then
	bserver=$3

	if ! [[ $bserver =~ ^[a-z0-9.-]+[.][a-z0-9]+([:][0-9]+)?$ ]]; then
		echo "error: parameter 3 not conforming host name format"
		exit 1
	fi

	if [ -z "${bserver##*:*}" ]; then
		bhost="${bserver%:*}"
		bport="${bserver##*:}"
	else
		bhost=$bserver
		bport=22
	fi

	if [ "`getent hosts $bhost`" = "" ]; then
		echo "error: host $bhost not found"
		exit 1
	fi
fi

path=/srv/imap/$1
useradd -u $uid -d $path -m -g imapusers -s /bin/false imap-$1
chmod 0711 $path
date +"%Y.%m.%d %H:%M" >$path/from.date

touch $path/.fetchmailrc
touch $path/.ignorepatterns
touch $path/.uidl

mkdir -p $path/Maildir/cur $path/Maildir/new $path/Maildir/tmp $path/logs

chmod -R 0700 $path/Maildir
chmod 0750 $path/logs
chmod 0660 $path/.ignorepatterns
chmod 0600 $path/.fetchmailrc $path/.uidl

rm $path/.bash_logout $path/.bashrc $path/.profile
chown -R imap-$1:imapusers $path

rkey=`ssh_management_key_storage_filename $rhost`
rsync -e "ssh -i $rkey -p $rport" -av $path root@$rhost:/srv/imap
ssh -i $rkey -p $rport root@$rhost "useradd -u $uid -d $path -M -g imapusers -G www-data -s /bin/false imap-$1"
ssh -i $rkey -p $rport root@$rhost "echo \"# */5 * * * * imap-$1 /opt/farm/ext/imap-server/cron/fetchmail.sh imap-$1 $1\" >>/etc/crontab"
ssh -i $rkey -p $rport root@$rhost "passwd imap-$1"

if [ "$3" != "" ] && [ "$3" != "$2" ]; then
	bkey=`ssh_management_key_storage_filename $bhost`
	rsync -e "ssh -i $bkey -p $bport" -av $path root@$bhost:/srv/imap
	ssh -i $bkey -p $bport root@$bhost "useradd -u $uid -d $path -M -g imapusers -s /bin/false imap-$1"
fi
