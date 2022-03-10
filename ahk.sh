#!/usr/bin/env bash
autohotkey "$1" &
while [ true ] ; do
  pid="$(\ps | grep autohotkey | awk '{print $1}')"
  # echo "pid: $pid"
  if [ -n "$pid" ]; then
    kill "$pid"
    exit
  fi
  sleep 1
done
