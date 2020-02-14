#!/bin/sh

PH=0
VM=0
CT=0
CL=0
LXC=0
DCK=0
XEN=0
WKS=0
PRB=0
DEF=1
command=$@

if [ "$1" = "" ]; then
	echo "usage: $0 [-ph] [-vm] [-ct] [-lxc] [-dck] [-wks] [-cl] [-prb] command argument(s)"
	exit 1
fi

while [ "$1" = "-ph" ] || [ "$1" = "-vm" ] || [ "$1" = "-ct" ] || [ "$1" = "-lxc" ] || [ "$1" = "-dck" ] || [ "$1" = "-xen" ] || [ "$1" = "-wks" ] || [ "$1" = "-cl" ] || [ "$1" = "-prb" ]; do
	DEF=0
	if   [ "$1" = "-ph" ]; then PH=1
	elif [ "$1" = "-vm" ]; then VM=1
	elif [ "$1" = "-ct" ]; then CT=1
	elif [ "$1" = "-cl" ]; then CL=1
	elif [ "$1" = "-lxc" ]; then LXC=1
	elif [ "$1" = "-dck" ]; then DCK=1
	elif [ "$1" = "-xen" ]; then XEN=1
	elif [ "$1" = "-wks" ]; then WKS=1
	elif [ "$1" = "-prb" ]; then PRB=1
	fi
	shift
	command=$@
done

# default behaviour, when no -xx switches are used: execute command only on virtual machines
if [ $DEF = 1 ]; then
	VM=1
fi


connect_loop() {
	for server in `cat /etc/local/.farm/$3 |grep -v ^#`; do
		/opt/farm/ext/farm-manager/internal/execute-proxy.sh $2 $server "$1" "$4"
	done
}

if [ $CL  = 1 ]; then connect_loop "$command" ssh cloud.hosts "cloud instance"; fi
if [ $WKS = 1 ]; then connect_loop "$command" ssh workstation.hosts "workstation"; fi
if [ $PRB = 1 ]; then connect_loop "$command" ssh problematic.hosts "problematic server"; fi
if [ $PH  = 1 ]; then connect_loop "$command" ssh physical.hosts "physical server"; fi
if [ $VM  = 1 ]; then connect_loop "$command" ssh virtual.hosts "virtual server"; fi
if [ $LXC = 1 ]; then connect_loop "$command" ssh lxc.hosts "LXC container"; fi
if [ $CT  = 1 ]; then connect_loop "$command" ssh container.hosts "container"; fi
if [ $DCK = 1 ]; then connect_loop "$command" docker docker.hosts ""; fi

if [ $XEN = 1 ]; then echo "skipping Xen containers; not implemented yet"; fi
