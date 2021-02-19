#!/bin/sh

/opt/farm/scripts/setup/extension.sh sm-farm-register

files="backup workstation problematic container physical virtual docker lxc cloud"

mkdir -p   ~/.farm
chmod 0700 ~/.farm

for db in $files; do
	touch      ~/.farm/$db.hosts
	chmod 0600 ~/.farm/$db.hosts
done

mkdir -p /etc/local/hooks /srv/imap /srv/rsync
