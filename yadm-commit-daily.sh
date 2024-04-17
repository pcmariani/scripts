#!/bin/bash

yadm add -u
yedm commit -m \
	"daily - \
  modified: $(yadm status | grep '.*modified:' | sed -e 's/.*modified: *//' -e 's/.*\///' | tr '\n' '|' | sed -e 's/\|$/\n/g' -e 's/\|/, /g')\
  ; \
  new files: $(yadm status | grep '.*new file:' | sed -e 's/.*new file: *//' -e 's/.*\///' | tr '\n' '|' | sed -e 's/\|$/\n/g' -e 's/\|/, /g')"
yadm push origin master