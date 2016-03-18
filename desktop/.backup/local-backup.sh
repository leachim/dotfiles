#!/bash/bin
## Backup script for local files of lesser importance

## files to backup
FILES="--include $HOME/Dropbox --include $HOME/.zotero --include $HOME/Data --exclude $HOME"

### Sign archives

duplicity --full-if-older-than 6M --volsize 500 --no-encryption --verbosity 5 $FILES $HOME sftp://storagebox/backup/$(hostname) 

