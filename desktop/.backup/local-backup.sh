#!/bash/bin
## Backup script for local files of lesser importance

## files to backup
FILES="--include $HOME/Dropbox --include $HOME/.zotero --include $HOME/.config/chromium/Default/Bookmarks --include $HOME/Data --include $HOME/Github --include $HOME/package-list --exclude $HOME --exclude $HOME/Dropbox/.dropbox.cache"

### Sign archives
dpkg --get-selections > ~/package-list

duplicity --full-if-older-than 6M --volsize 500 --no-encryption --verbosity 5 $FILES $HOME sftp://storagebox/backup/$(hostname) 

rm -f ~/package-list

## howto restore
# duplicity sft://storagebox/backup/$(hostname) to_restore
