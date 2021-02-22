#!/usr/bin/env bash

file=$HOME/notes.mkd

regex_dateline='^[0-9]{2}-[A-Za-z]{3}-[0-9]{4}\s*$'
regex_dashline='-----------'
regex_tagline='^`.*[0-9]{10}-->'

notes=(\"Id\",\"Date\",\"Tags\",\"Note\")
note=()

# Read each line. This is slow in bash.
while IFS="" read -r line || [ -n "$line" ]
do
    if  ! [[ "$line" =~ $regex_dateline ]] &&
        ! [[ "$line" =~ $regex_dashline ]] && 
        ! [[ "$line" =~ $regex_tagline ]]
    then
        notestr+="$line\n"

    # Subshells are making it even slower
    elif [[ "$line" =~ $regex_tagline ]]
    then
        id="$(echo $line | grep -oP '[0-9]{10}')"
        datestr="$(date -d @"$id" +'%Y-%m-%d %H:%M:%S')"
        tags="$(echo $line | sed 's/`//g' | grep -oP '#\S+' | tr -d '#' | tr '\n' ' ' | sed 's/ $//')"
        notestr=$(echo "$notestr" | sed -e 's/^\\n//' -e 's/"/""/g' -e 's/\\n$//')

        note+=("\"$id\"","\"$datestr\"","\"$tags\"","\"$notestr\"")
        notes+=("${note[*]}")

        unset note
        unset notestr
    fi
done < "$file"

IFS=$'\n'; echo "${notes[*]}" #> tmp_parsednotes

