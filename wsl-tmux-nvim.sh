#!/usr/bin/env bash

fullpath="$1"
tmux_prefix="·"
nvim_prefix="lnx__"
if [[ "$1" == *\\* ]]; then
  fullpath=$(wslpath -u "$1")
  tmux_prefix="·"
  nvim_prefix="win__"
fi
dir=$(dirname "$fullpath")
file="$(basename "$fullpath")"
tmux_session="$tmux_prefix"$(sed -e 's/^.*\///' -e 's/ /_/g' <<<"$dir")
  # -e 's/^\///' \
  # -e 's/^\/home\/pete/~/' \
  # -e 's/^\/mnt\/[A-Za-z]\///' \
  # -e 's/Users\///' \
  # -e 's/PeterMariani/PM/' \
tmux_window_name="neovim"
nvim_remote_pipe="$nvim_prefix"$(sed -e 's/^.*\///' -e 's/ /_/g' <<< "$dir")".pipe"

# tmux has-session -t "main" 2> /dev/null
# if [ $? -ne 0 ]; then
#   tmux new-session -d -s "main" -n "$tmux_window_name" -c "$HOME"
# fi
# tmux switch -t "main"

tmux has-session -t "$tmux_session" 2> /dev/null
if [ $? -ne 0 ]; then
  echo "01 tmux session $tmux_session does not exist"
  tmux new-session -d -s "$tmux_session"  -n "$tmux_window_name" -c "$dir"
  echo "02 tmux session $tmux_session created & tmux window $tmux_window_name created"
  tmux send-keys -t "$tmux_session:$tmux_window_name" "nvim --listen /tmp/$nvim_remote_pipe '""$file""'" C-m
  echo "03 nvim pipe $nvim_remote_pipe created"
  tmux switch -t "$tmux_session:$tmux_window_name"
  exit 0
else
  echo "04 tmux session $tmux_session exists"
  ps a | grep -v grep | grep "$nvim_remote_pipe" 1> /dev/null # <--- make grep more specifit
  if [ $? -ne 0 ]; then
    echo "05 nvim pipe $nvim_remote_pipe does not exist"
    tmux has-session -t "$tmux_session:$tmux_window_name" 2> /dev/null
    if [ $? -ne 0 ]; then
      tmux new-window -n "$tmux_window_name" -c "$dir" -t "$tmux_session":
      echo "06 tmux window $tmux_window_name created"
    else
      echo "07 tmux window $tmux_window_name exists"
    fi
    tmux send-keys -t "$tmux_session:$tmux_window_name" "nvim --listen /tmp/$nvim_remote_pipe $file" C-m
    echo "08 nvim pipe $nvim_remote_pipe created"
    tmux switch -t "$tmux_session:$tmux_window_name" 2> /dev/null
    exit 0
  else
    echo "09 nvim pipe $nvim_remote_pipe exists"
    tmux has-session -t "$tmux_session:$tmux_window_name" 2> /dev/null
    if [ $? -ne 0 ]; then
      echo "10 tmux window $tmux_window_name does not exist, will not be created"
      tmux_window_index=$(($(ps a | grep -v grep | grep /tmp/win__ | cut -d' ' -f3 | cut -d'/' -f2) - 1))
      echo "11 tmux window index containing nvim instance: $tmux_window_index"
      tmux send-keys -t "$tmux_session:$tmux_window_index" "^z" C-m
      tmux send-keys -t "$tmux_session:$tmux_window_index" "fg nvim" C-m
      nvim --server "/tmp/$nvim_remote_pipe" --remote "$file"
      echo "12 nvim pipe $nvim_remote_pipe connected"
      tmux switch -t "$tmux_session:$tmux_window_index" 2> /dev/null
      exit 0
    else
      echo "13 tmux window $tmux_window_name exists"
      tmux send-keys -t "$tmux_session:$tmux_window_name" "^z" C-m
      tmux send-keys -t "$tmux_session:$tmux_window_name" "fg nvim" C-m
      nvim --server "/tmp/$nvim_remote_pipe" --remote "$file"
      echo "14 nvim pipe $nvim_remote_pipe connected"
      tmux switch -t "$tmux_session:$tmux_window_name" 2> /dev/null
      exit 0
    fi
  fi
fi

# echo "fullpath: $fullpath"
# echo "dir: $dir"
# echo "file: $file"
# echo "tmux_session: $tmux_session"
# echo "nvim_remote_pipe: $nvim_remote_pipe"

# Just windows
# 1. check/create for main session
# 2. switch to main session
# 3. check/create for win-work session
# 4. eheck nvim pipe <-- must assume that nvim pipe and tmux window name are the same
# 5. if pipe exists, add file to it and switch to tmux window
# 6. if pipe does not exist, create it and check/create tmux window
