#!/bin/sh

/opt/farm/scripts/setup/extension.sh sf-net-utils

path="/etc/local/.farm"
files="
$path/backup.hosts
$path/workstation.hosts
$path/problematic.hosts
$path/physical.hosts
$path/virtual.hosts
$path/docker.hosts
$path/openvz.hosts
$path/lxc.hosts
$path/cloud.hosts
"

mkdir -p $path
chmod 0700 $path

for db in $files; do
	touch $db
	chmod 0600 $db
done

mkdir -p /etc/local/hooks /srv/imap /srv/rsync

ln -sf /opt/farm/ext/farm-manager/add-dedicated-key.sh /usr/local/bin/add-dedicated-key
ln -sf /opt/farm/ext/farm-manager/add-managed-host.sh /usr/local/bin/add-managed-host
ln -sf /opt/farm/ext/farm-manager/execute.sh /usr/local/bin/sf-execute
ln -sf /opt/farm/ext/farm-manager/console.sh /usr/local/bin/sf-console
ln -sf /opt/farm/ext/farm-manager/run.sh /usr/local/bin/sf-run
