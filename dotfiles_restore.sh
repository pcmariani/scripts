#!/usr/bin/env bash

cd $HOME

function dot {
   /usr/bin/git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME $@
}

echo ".dotrepo" >> .gitignore

# if [ ! -d $HOME/.dotrepo ]; then
#     git clone --bare git@github.com:pcmariani/dotfiles.git $HOME/.dotrepo
# else
#     echo "The directory $HOME/.dotrepo already exists...Aborting."
#     exit 1
# fi

dot checkout 2>/dev/null
if [ $? = 0 ]; then
    echo "Dotfiles checked out."
    echo "Success!"
else
    backupdir=.dotrepo-backup
    echo "Backing up pre-existing dot files to $backupdir."

    filepaths="$(dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'})"

    for filepath in $filepaths; do
        mkdir -p "$backupdir/${filepath%/*}"
       	mv "$filepath" "$backupdir/$filepath"
    done

    dot checkout
    if [ $? = 0 ]; then
        dot config status.showUntrackedFiles no
        echo "Dotfiles checked out."
        echo "Success!"
    else
        echo "Cannot checkout dotfiles...Aborting."
    fi
fi

