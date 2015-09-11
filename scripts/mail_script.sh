#!/bin/bash

## template for creating bash script that notifies user after completion via mail

$USER = $(whoami)
# time duration of processing
function timer()
{
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}

#tmpFolder="/home/$USER/qsub/tmpfiles/"
#T=$(head -1 "${tmpFolder}result")

## Alert user of process end
# Get time as a UNIX timestamp (seconds elapsed since Jan 1, 1970 0:00 UTC)
printf -v runtime 'runtime: %s' "$(timer $T)"
echo $runtime >> "${tmpFolder}result"

mail -s "job finished for user"$(whoami) "mail@mail.de" < "${tmpFolder}result"
