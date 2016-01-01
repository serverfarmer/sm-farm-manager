#!/bin/sh

if [ -h /usr/local/bin/add-managed-host ]; then
	rm -f /usr/local/bin/add-managed-host
fi

if [ -h /usr/local/bin/sf-execute ]; then
	rm -f /usr/local/bin/sf-execute
fi
