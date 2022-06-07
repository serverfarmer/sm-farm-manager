#!/bin/sh
# Search registered servers for installed Docker engine (not
# necessarily running containers at the time of the scan).


scan_loop() {
	for server in `grep -v ^# ~/.serverfarmer/inventory/$1`; do

		host=`/opt/farm/mgr/farm-manager/internal/decode.sh host $server`
		port=`/opt/farm/mgr/farm-manager/internal/decode.sh port $server`

		sshkey=`/opt/farm/ext/keys/get-ssh-management-key.sh $host`
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
