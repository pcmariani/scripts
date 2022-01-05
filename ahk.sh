#!/usr/bin/env bash
autohotkey "$1" &
while [ true ] ; do
  sleep 2
  pid="$(\ps | grep autohotkey | awk '{print $1}')"
  kill "$pid"
  return
done
