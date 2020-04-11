#!/bin/sh

# Backup zotero folder to tar archive
TIME=`date +%Y_%m_%d`            # This Command will add date in Backup File Name.
FILENAME=zotero-$(hostname)-$TIME.archive.tar.gz    # Here i define Backup file name format.
DESDIR=~/.backup/         # Destination of backup file.
tar cpzf $DESDIR/$FILENAME -C $HOME/.zotero/ zotero
#END
