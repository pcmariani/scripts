# need github link
function dotrepo {
   /usr/bin/git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME $@
}
mkdir -p .dotrepo-backup
dotrepo checkout
if [ $? = 0 ]; then
  echo "Checked out dotrepo.";
  else
    echo "Backing up pre-existing dot files.";
    dotrepo checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotrepo-backup/{}
fi;
dotrepo checkout
dotrepo config status.showUntrackedFiles no
