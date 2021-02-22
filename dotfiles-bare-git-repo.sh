#!/usr/bin/env bash

function dot {
   /usr/bin/git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME $@
}

echo ".dotrepo" >> .gitignore

if [ ! -d $HOME/.dotrepo ]; then
    git clone --bare https://github.com/pcmariani/dotfiles $HOME/.dotrepo
else
    echo "The directory $HOME/.dotrepo already exists. Aborting."
    exit 1
fi

dot checkout 2>/dev/null
if [ $? = 0 ]; then
    echo "Checked out config."
else
    echo "Backing up pre-existing dot files."

    backupdir=.dotrepo-backup
    filepaths="$(dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'})"  #| xargs -I{} mv {} .dotrepo-backup/{}

    for filepath in $filepaths; do
	mkdir -p "$backupdir/${filepath%/*}"
	mv "$filepath" "$backupdir/$filepath"
    done
fi

dot checkout
dot config status.showUntrackedFiles no
