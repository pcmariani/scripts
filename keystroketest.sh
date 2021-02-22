#!/bin/bash

SELECT=""
# prevent parsing of the input line
line=''
IFS=''
while [[ "$SELECT" != $'\x0a' && "$SELECT" != $'\x20' ]]; do
  #echo "Select session type:"
  #echo "Press <Enter> to do foo"
  #echo "Press <Space> to do bar"
  # read -s -N 1 SELECT
  read -N 1 SELECT
  line+="$SELECT"
  # echo -n "$SELECT"
  #echo "Debug/$SELECT/${#SELECT}"
  [[ "$SELECT" == $'\x0a' ]] && echo "$line <you pressed enter>" # do foo
  [[ "$SELECT" == $'\x20' ]] && echo "space" # do bar
done
