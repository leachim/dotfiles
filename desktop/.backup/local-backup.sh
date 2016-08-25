#!/bash/bin
## Backup script for local files of lesser importance

## files to backup
FILES="--include $HOME/Dropbox --include $HOME/.zotero --include $HOME/Data --include $HOME/Github --include $HOME/package-list --exclude $HOME"

### Sign archives
dpkg --get-selections > ~/package-list

duplicity --full-if-older-than 6M --volsize 500 --no-encryption --verbosity 5 $FILES $HOME sftp://storagebox/backup/$(hostname) 

rm -f ~/package-list
