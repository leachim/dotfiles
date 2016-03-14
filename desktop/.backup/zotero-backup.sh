#!/bin/sh

# Backup zotero folder to tar archive
TIME=`date +%b-%d-%y`            # This Command will add date in Backup File Name.
FILENAME=$TIME-zotero.tar.gz    # Here i define Backup file name format.
SRCDIR=~/.zotero/zotero                    # Location of Important Data Directory (Source of backup).
DESDIR=~/Downloads         # Destination of backup file.
tar -cpzf $DESDIR/$FILENAME $SRCDIR
#END
