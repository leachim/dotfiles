#!/bin/sh

# Backup zotero folder to tar archive
TIME=`date +%d_%m_%y`            # This Command will add date in Backup File Name.
FILENAME=zotero-archive-$(hostname)-$TIME.tar.gz    # Here i define Backup file name format.
DESDIR=~/.backup/         # Destination of backup file.
tar cpzf $DESDIR/$FILENAME -C $HOME/.zotero/ zotero
#END
