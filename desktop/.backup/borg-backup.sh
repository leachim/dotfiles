#!/bin/bash
## borg backup script
LOG="~/Downloads/borgbackup.log"

# initialize backup repository, only needed for new installations, on one line, replace $(hostname) with actual value
#BORG_RSH="ssh -i ~/.ssh/borg_$(hostname)" borg init --encryption=keyfile ssh://storagebox:23/./borg/$(hostname) --debug

# list all archives in the repository:
# BORG_RSH="ssh -i ~/.ssh/borg_$(hostname)" borg list ssh://storagebox:23/./borg/$(hostname)

# list the contents of the Monday archive:
# BORG_RSH="ssh -i ~/.ssh/borg_$(hostname)" borg list ssh://storagebox:23/./borg/$(hostname)::archivename

# restore archive, see https://borgbackup.readthedocs.io/en/stable/usage/extract.html for more examples, note to remove leading /
# first, recreate repository
# BORG_RSH="ssh -i ~/.ssh/borg_$(hostname)" borg key import ssh://storagebox:23/./borg/$(hostname) path/to/key
# BORG_RSH="ssh -i ~/.ssh/borg_$(hostname)" borg extract ssh://storagebox:23/./borg/$(hostname)::glaux-laptop-2017-12-30T21:55:49 home/$(username)/src


# Setting this, so the repo does not need to be given on the commandline:
export BORG_RSH="ssh -i ~/.ssh/borg_$(hostname)"
export BORG_REPO=ssh://storagebox:23/./borg/$(hostname)
#ssh://username@example.com:2022/~/backup/main

# # Setting this, so you won't be asked for your repository passphrase:
# export BORG_PASSPHRASE='XYZl0ngandsecurepa_55_phrasea&&123'
# # or this to ask an external program to supply the passphrase:
# export BORG_PASSCOMMAND='pass show backup'
# echo "Enter password"
# unset -v BORG_PASSPHRASE # make sure it's not exported
# set +a            # make sure variables are not automatically exported
# IFS= read -rs BORG_PASSPHRASE < /dev/tty &&

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

## Output to a logfile
# exec > >(tee -i ${LOG})
# exec 2>&1

apt-mark showmanual > ~/manual_installed_packages_$(date +%Y_%m_%d-%H_%M_%S)
dpkg --get-selections > ~/all_installed_packages_$(date +%Y_%m_%d-%H_%M_%S)

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

borg create                                 \
    --verbose                               \
    --filter AME                            \
    --list                                  \
    --stats                                 \
    --show-rc                               \
    --compression lzma,6                    \
    --exclude-caches                        \
    --exclude '/home/*/.cache/*'            \
                                            \
    --exclude '/etc/.pwd.lock'              \
    --exclude '/etc/apparmor.d/*'           \
    --exclude '/etc/audit'                  \
    --exclude '/etc/audisp'                 \
    --exclude '/etc/cups/ssl'               \
    --exclude '/etc/cups/printers.conf*'    \
    --exclude '/etc/cups/subscriptions.conf*'\
    --exclude '/etc/docker/key.json'        \
    --exclude '/etc/default/cacerts'        \
    --exclude '/etc/exim4/passwd.client'    \
    --exclude '/etc/gshadow*'               \
    --exclude '/etc/logcheck/*'             \
    --exclude '/etc/lvm/backup'             \
    --exclude '/etc/NetworkManager/system-connections/*'\
    --exclude '/etc/ppp/*-secrets'          \
    --exclude '/etc/polkit-1/localauthority'\
    --exclude '/etc/security/opasswd'       \
    --exclude '/etc/subuid*'                \
    --exclude '/etc/sudoers*'               \
    --exclude '/etc/vpnc'                   \
    --exclude '/etc/subgid*'                \
    --exclude '/etc/shadow*'                \
    --exclude '/etc/ssl/private'            \
                                            \
    --exclude '/home/*/.anaconda3/pkgs/*'   \
    --exclude '/home/*/.anaconda3/conda-bld/*'\
    --exclude '/home/*/.config/borg/*'      \
    --exclude '/home/*/.config/doctl/*'     \
    --exclude '/home/*/.config/gcloud/*'    \
    --exclude '/home/*/.config/geany/*'     \
    --exclude '/home/*/.config/VirtualBox/*'\
    --exclude '/home/*/.dbus/*'             \
    --exclude '/home/*/.dockercfg'          \
    --exclude '/home/*/.dropbox/*'          \
    --exclude '/home/*/.dropbox-dist/*'     \
    --exclude '/home/*/.gcalcli_oauth'      \
    --exclude '/home/*/.grip/*'             \
    --exclude '/home/*/.kube/*'             \
    --exclude '/home/*/.miniconda3/pkgs/*'  \
    --exclude '/home/*/.miniconda3/conda-bld/*'\
    --exclude '/home/*/.xsession-errors'    \
    --exclude '/home/*/.zcompdump'          \
    --exclude '/home/*/.zcompcache'         \
                                            \
    --exclude '/home/*/*_oauth'             \
    --exclude '/home/*/**/*_oauth'          \
    --exclude '/home/*/.*_history'          \
                                            \
    --exclude '/home/*/.aws/*'              \
    --exclude '/home/*/.backup/*'           \
    --exclude '/home/*/.dotfiles/*'         \
    --exclude '/home/*/.encrypted/*'        \
    --exclude '/home/*/.gmvault/*'          \
    --exclude '/home/*/.gnupg/*'            \
    --exclude '/home/*/.pki/*'              \
    --exclude '/home/*/.ssh/*'              \
    --exclude '/home/*/*/streisand/global_vars/*'\
    --exclude '/home/*/*/streisand/generated-docs/*'\
                                            \
    --exclude '/home/*/.config/chromium/*'  \
    --exclude '/home/*/.mozilla/*'          \
    --exclude '/home/*/.travis/*'           \
    --exclude '/home/*/.virtualbox/*'       \
                                            \
    --exclude '/home/*/Data/*'              \
    --exclude '/home/*/Downloads/*'         \
    --exclude '/home/*/VirtualBox VMs/*'    \
                                            \
    ::'{hostname}-{now}'                    \
    /opt                                    \
    /etc                                    \
    /home                                   \

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}-' prefix is very important to
# limit prune's operation to this machine's archives and not apply to
# other machines' archives also:

borg prune                          \
    --list                          \
    --prefix '{hostname}-'          \
    --show-rc                       \
    --keep-within 7d                \
    --keep-daily    14              \
    --keep-weekly   8               \
    --keep-monthly  12              \
    --keep-yearly   4               \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 1 ];
then
    info "Backup and/or Prune finished with a warning"
    notify-send "$(hostname): $(date '+%Y-%m-%d %H:%M:%S') - Borg warning" "Borg finished with a warning.\nBackup exit: $backup_exit\nPrune exit: $prune_exit" --urgency=normal
fi

if [ ${global_exit} -gt 1 ];
then
    info "Backup and/or Prune finished with an error"
    notify-send "$(hostname): $(date '+%Y-%m-%d %H:%M:%S') - Borg error" "Borg finished with an error.\nBackup exit: $backup_exit\nPrune exit: $prune_exit" --urgency=critical
fi

rm -f ~/manual_installed_packages_*
rm -f ~/all_installed_packages_*

# unset -v $BORG_PASSPHRASE
exit ${global_exit}

