#!/usr/bin/env bash

ssh-add -l -t 1m &>/dev/null

if [ "$?" == 2 ]; then
  test -r ~/.ssh-agent && eval "$(<~/.ssh-agent)" >/dev/null
  ssh-add -l -t 1m &>/dev/null

  if [ "$?" == 2 ]; then
    (umask 066; ssh-agent -t 1m > ~/.ssh-agent)
    eval "$(<~/.ssh-agent)" >/dev/null
    ssh-add -t 1m
  fi
fi
