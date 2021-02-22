#!/usr/bin/env bash

r=".X.XX.X."
#r=".XX..XX."

declare -A ruleSet
ruleSet[...]="${r:0:1}"
ruleSet[..X]="${r:1:1}"
ruleSet[.X.]="${r:2:1}"
ruleSet[.XX]="${r:3:1}"
ruleSet[X..]="${r:4:1}"
ruleSet[X.X]="${r:5:1}"
ruleSet[XX.]="${r:6:1}"
ruleSet[XXX]="${r:7:1}"

function echo_joined_array { local IFS="$1"; shift; echo "$*" \
    | sed -e 's/\./ /g' -e 's/X/_/g' ; }

array=(. . . . . . . . . . . . . . . . . . . . . . . \
    . . . . . . . . . . . . . . . . . . . . . . . . \
    . . . . . . . . . . . . . \
    X . . . . . . . . . . . . . . . . . . . . . . . \
    . . . . . . . . . . . . . . . . . . . . . . . . .)

echo_joined_array '' "${array[@]}"

iterations=200

for (( x=0; x<"$iterations"; x++ ))
do
    newArr=(.)
     
    for (( i=1; i<"${#array[@]}"-1; i++ ))
    do
        cellState="${array[$i-1]}"
        cellState+="${array[$i]}"
        cellState+="${array[$i+1]}"
        
        newArr+=( "${ruleSet[$cellState]}" )
    done

    newArr+=(.)
    echo_joined_array '' "${newArr[@]}"
    
    unset array
    array=("${newArr[@]}")

    unset newArr

done
