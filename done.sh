#!/bin/bash

temp=""
log="$HOME/tasklog"

while IFS= read -r line
do
    #echo "$line"
    temp+=sed -i "/$line/d" "$temp"
done <<< $(grep 'END' "$log" | cut -f4)

echo "$temp"
