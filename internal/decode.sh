#!/bin/bash

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <field> <entry>"
  exit 1
elif ! [[ "$1" =~ ^(host|port|tag|timeout)$ ]]; then
  echo "error: invalid field \"$1\""
  exit 1
fi

field=$1
server=$2

DEFAULT_TIMEOUT=5
DEFAULT_PORT=22

if [[ $server =~ ^[a-z0-9.-]+$ ]]; then
  server="$server::"
elif [[ $server =~ ^[a-z0-9.-]+[:][0-9]+$ ]]; then
  server="$server:"
fi

case "$field" in
host)
  echo "$server" | cut -d: -f1
  ;;
tag)
  echo "$server" | cut -d: -f3
  ;;
timeout)
  timeout=$(echo "$server" | cut -d: -f4)
  if [ "$timeout" = "" ]; then timeout=$DEFAULT_TIMEOUT; fi
  echo $timeout
  ;;
port)
  port=$(echo "$server" | cut -d: -f2)
  if [ "$port" = "" ]; then port=$DEFAULT_PORT; fi
  echo $port
  ;;
esac
