#!/bin/sh

if [ -h /usr/local/bin/add-dedicated-key ]; then
	rm -f /usr/local/bin/add-dedicated-key
fi

if [ -h /usr/local/bin/add-managed-host ]; then
	rm -f /usr/local/bin/add-managed-host
fi

if [ -h /usr/local/bin/add-imap-user ]; then
	rm -f /usr/local/bin/add-imap-user
fi

if [ -h /usr/local/bin/add-rsync-user ]; then
	rm -f /usr/local/bin/add-rsync-user
fi

if [ -h /usr/local/bin/add-samba-user ]; then
	rm -f /usr/local/bin/add-samba-user
fi

if [ -h /usr/local/bin/sf-execute ]; then
	rm -f /usr/local/bin/sf-execute
fi

if [ -h /usr/local/bin/sf-console ]; then
	rm -f /usr/local/bin/sf-console
fi

if [ -h /usr/local/bin/sf-run ]; then
	rm -f /usr/local/bin/sf-run
fi
