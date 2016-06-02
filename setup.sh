#!/bin/sh

path="/etc/local/.farm"
files="$path/backup.hosts $path/workstation.hosts $path/problematic.hosts $path/physical.hosts $path/virtual.hosts $path/openvz.hosts $path/ec2.hosts $path/mikrotik.hosts $path/cisco.hosts"

mkdir -p $path
chmod 0700 $path

for db in $files; do
	touch $db
	chmod 0600 $db
done

mkdir -p /srv/imap /srv/rsync

ln -sf /opt/farm/ext/farm-manager/add-dedicated-key.sh /usr/local/bin/add-dedicated-key
ln -sf /opt/farm/ext/farm-manager/add-managed-host.sh /usr/local/bin/add-managed-host
ln -sf /opt/farm/ext/farm-manager/execute.sh /usr/local/bin/sf-execute
ln -sf /opt/farm/ext/farm-manager/console.sh /usr/local/bin/sf-console
ln -sf /opt/farm/ext/farm-manager/run.sh /usr/local/bin/sf-run
