#!/bin/bash
# Search registered servers for installed Docker engine (not
# necessarily running containers at the time of the scan).


scan_loop() {
	for server in `cat /etc/local/.farm/$1 |grep -v ^#`; do

		if [[ $server =~ ^[a-z0-9.-]+$ ]]; then
			server="$server::"
		elif [[ $server =~ ^[a-z0-9.-]+[:][0-9]+$ ]]; then
			server="$server:"
		fi

		host=$(echo $server |cut -d: -f1)
		port=$(echo $server |cut -d: -f2)

		if [ "$port" = "" ]; then
			port=22
		fi

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
