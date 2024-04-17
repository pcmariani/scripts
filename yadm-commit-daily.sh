#!/bin/bash

messageArr=()

modified="$(yadm status | grep '.*modified:')"
new_files="$(yadm status | grep '.*new files:')"
deleted="$(yadm status | grep '.*deleted:')"

if [ "$modified" != "" ]; then
	messageArr=("${messageArr[@]}" "modified $(echo $modified | sed -e 's/.*modified: *//' -e 's/.*\///' | tr '\n' '|' | sed -e 's/\|$/\n/g' -e 's/\|/, /g')")
fi

if [ "$new_files" != "" ]; then
	messageArr=("${messageArr[@]}" "added $(echo $new_files | sed -e 's/.*new_files: *//' -e 's/.*\///' | tr '\n' '|' | sed -e 's/\|$/\n/g' -e 's/\|/, /g')")
fi

if [ "$deleted" != "" ]; then
	messageArr=("${messageArr[@]}" "deleted $(echo $deleted | sed -e 's/.*deleted: *//' -e 's/.*\///' | tr '\n' '|' | sed -e 's/\|$/\n/g' -e 's/\|/, /g')")
fi

join() {
	local IFS="|"
	echo "$*"
}
res="autocommit > $(join "${messageArr[@]}" | sed "s/\|/ : /g")"
echo "$res"

yadm add -u
yadm commit -m "$message"
yadm push origin master
