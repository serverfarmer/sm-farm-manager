#!/bin/sh
# Search registered servers for installed Docker engine (not
# necessarily running containers at the time of the scan).


scan_loop() {
	for server in `cat /etc/local/.farm/$1 |grep -v ^#`; do

		host=`/opt/farm/ext/farm-manager/internal/decode.sh host $server`
		port=`/opt/farm/ext/farm-manager/internal/decode.sh port $server`

		sshkey=`/opt/farm/ext/keys/get-ssh-management-key.sh $host`
		result="`$SSH -q -t -i $sshkey -p $port -o StrictHostKeyChecking=no -o ConnectTimeout=10 root@$host \"which docker 2>/dev/null\"`"

		if [ "$result" != "" ]; then
			echo $server
		fi
	done
}


SSH=/opt/farm/ext/binary-ssh-client/wrapper/ssh

scan_loop physical.hosts
scan_loop virtual.hosts
scan_loop cloud.hosts
scan_loop problematic.hosts
scan_loop workstation.hosts
