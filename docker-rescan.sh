#!/bin/bash
. /opt/farm/scripts/functions.custom
# Search registered servers for installed Docker engine (not
# necessarily running containers at the time of the scan).


scan_loop() {
	for server in `cat /etc/local/.farm/$1 |grep -v ^#`; do

		if [ -z "${server##*:*}" ]; then
			host="${server%:*}"
			port="${server##*:}"
		else
			host=$server
			port=22
		fi

		sshkey="`ssh_management_key_storage_filename $host`"
		result="`ssh -q -t -i $sshkey -p $port -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@$host \"which docker 2>/dev/null\"`"

		if [ "$result" != "" ]; then
			echo $server
		fi
	done
}


scan_loop physical.hosts
scan_loop virtual.hosts
scan_loop cloud.hosts
scan_loop problematic.hosts
scan_loop workstation.hosts
