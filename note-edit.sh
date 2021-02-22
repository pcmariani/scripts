#!/usr/bin/env bash

# input: name of note
# steps:
# * get list of active notes
# * get id of disired note by title
# * create temp file with contents
# * pipe temp file into vim
# * (file is edited)
# * vim saves tempfile
# * replace contents of existing note with temp file
# * trigger sncli sync
# * delete temp file

NOTEDIR=$HOME/.sncli
# IFS='g,'
active_notes=($(grep -HRl 'deleted.*false' "$NOTEDIR"/*.json ))

# echo "${active_notes_ids_arr[@]}"
# | head -n1 
note_id="$(grep 'content\"\s*:\s*\"simplenote' ${active_notes[@]} | sed 's/$NOTEDIR//')"
note_filename="$NOTEDIR/$note_id.json"

echo "$note_id"
echo "$note_filename"

# for i in "${active_notes_ids_arr[@]}"; do
#     jq -r '.tags[]' "$i"
# done | sort -u

#alias -g nactive="grep 'deleted.*false' $NOTEDIR/*.json | sed 's/:.*//'"
#alias ntags="for i in \$(nactive); do jq -r '.tags[]' \$i; done | sort -u"
#function ntag() { for i in $(ngrepbytag $@); do echo -n "$i: "; jq -r '.content' $i | head -n1 | tr -d '\n$'; jq '.content' $i; done }
#tempcontent() { jq -r '.content' "$@" > ~/temp$(echo "$@" | sed 's/.json//').mkd }
#jqmv() { jq --arg c "$(cat ~/temp"$@".mkd)" '.content = $c' ~/.sncli/"$@".json > ~/temp"$@".json && mv ~/temp"$@".json ~/.sncli/"$@".json }


