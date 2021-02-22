#!/usr/bin/env bash

function dot {
   /usr/bin/git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME $@
}

echo ".dotrepo" >> .gitignore

git clone --bare https://github.com/pcmariani/dotfiles $HOME/.dotrepo

mkdir -p .dotrepo-backup
dot checkout

if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotrepo-backup/{}
fi;

dot checkout
dot config status.showUntrackedFiles no
