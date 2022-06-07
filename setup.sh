#!/bin/sh

/opt/farm/scripts/setup/extension.sh sm-farm-register

files="backup workstation problematic container physical virtual docker lxc cloud"

mkdir -p   ~/.serverfarmer/inventory
chmod 0700 ~/.serverfarmer/inventory

for db in $files; do
	touch      ~/.serverfarmer/inventory/$db.hosts
	chmod 0600 ~/.serverfarmer/inventory/$db.hosts
done

mkdir -p ~/.serverfarmer/hooks /srv/imap /srv/rsync


if [ -x /etc/local/hooks/ssh-accounting.sh ] && [ "`whoami`" = "root" ]; then
	mv -f /etc/local/hooks/ssh-accounting.sh ~/.serverfarmer/hooks
fi
