#!/usr/bin/env bash

fullpath=$(wslpath -u "$1")
dir=$(dirname "$fullpath")
file="$(basename "$fullpath")"
tmux_session=" work"
tmux_window="nvim:  "$(sed -e 's/^.*\///' -e 's/ /_/g' <<<"$dir")
nvim_pipe="winwork_"$(sed -e 's/^.*\///' -e 's/ /_/g' <<< "$dir")".pipe"

# echo "fullpath: $fullpath"
# echo "dir: $dir"
# echo "file: $file"
# echo "tmux_session: $tmux_session"
# echo "tmux_window: $tmux_window"
# echo "nvim_pipe: $nvim_pipe"

tmux has-session -t "$tmux_session" 2> /dev/null
if [ $? -ne 0 ]; then
  # echo "01 tmux session $tmux_session does not exist"
  tmux new-session -d -s "$tmux_session" -n "$tmux_window" -c "$dir"
  # echo "02 tmux session $tmux_session created & tmux window $tmux_window created"
  tmux send-keys -t "$tmux_session:$tmux_window" "nvim --listen /tmp/$nvim_pipe '""$file""'" C-m
  # echo "03 nvim pipe $nvim_pipe created"
  tmux switch -t "$tmux_session:$tmux_window"
else
  # echo "04 tmux session $tmux_session exists"
  ps a | grep -v grep | grep "$nvim_pipe" 1> /dev/null # <--- make grep more specifit
  if [ $? -ne 0 ]; then
    # echo "05 nvim pipe $nvim_pipe does not exist"
    tmux has-session -t "$tmux_session:$tmux_window" 2> /dev/null
    if [ $? -ne 0 ]; then
      tmux new-window -n "$tmux_window" -c "$dir" -t "$tmux_session":
      # echo "06 tmux window $tmux_window created"
    # else
      # echo "07 tmux window $tmux_window exists"
    fi
    tmux send-keys -t "$tmux_session:$tmux_window" "nvim --listen /tmp/$nvim_pipe '""$file""'" C-m
    # echo "08 nvim pipe $nvim_pipe created"
    tmux switch -t "$tmux_session:$tmux_window" 2> /dev/null
  else
    # echo "09 nvim pipe $nvim_pipe exists"
    # # echo "10 tmux window $tmux_window exists"
    tmux send-keys -t "$tmux_session:$tmux_window" "^z" C-m
    tmux send-keys -t "$tmux_session:$tmux_window" "fg nvim" C-m
    nvim --server "/tmp/$nvim_pipe" --remote "$file"
    # echo "11 nvim pipe $nvim_pipe connected"
    tmux switch -t "$tmux_session:$tmux_window" 2> /dev/null
  fi
fi
echo $(fg)
exit 0

# Just windows
# 1. check/create for main session
# 2. switch to main session
# 3. check/create for win-work session
# 4. eheck nvim pipe <-- must assume that nvim pipe and tmux window name are the same
# 5. if pipe exists, add file to it and switch to tmux window
# 6. if pipe
