#!/bin/bash

####################################
### Backup settings
####################################
_TIMESTAMP=`date +%Y_%m_%d-%H_%M`
_SRC="/home/$(whoami)/.encrypted/" ## directory to backup
_DEST="/home/$(whoami)/.backup/" ## backup directory
#_RESTORE="/home/$(whoami)/.restore/" ## restore directory, potential restore directory
_EXCLUDEDIR="**excludeFromBackup/**" ## excluded from backup
_LOG="/home/$(whoami)/duplicity-backup-$_TIMESTAMP.log" ## log file

### Sign archives
_SIGN_KEY=4FF90AD4
export SIGN_PASSPHRASE=""

####################################
### Verify password
####################################

## check backup directory exists
if [ ! -d "$_DEST" ]; then
    printf "BACKUP DIRECTORY DOES NOT EXIST"
    exit -1
fi

# Comment this out before using script
echo "salt is not correct yet, is a function of password at the end"
exit 1

## PASSWORD SALTS
_SALT="IiNb6ckUGAJmw"
_HASH="RMkyNZvpBzIZfyqPsvcnhihuUI16VMshVwKQJWvKL1PE9TYsttkUdo9aS5LUDmwAQzDRO8qlZti6Bib36cjBt0"

printf "Please enter the correct password for encryption\n"
_MYHASH=$(mkpasswd --method=sha-512 --salt=$_SALT --rounds=99999999)
_MYHASH=${_MYHASH##*$}
export PASSPHRASE=$_PASSPHRASE

# check if password is correct
if [ "$_MYHASH" != "$_HASH" ]; then
  printf "WRONG PASSWORD!"
	unset _SALTA
	unset _SALTB
	unset _HASH
	unset SIGN_PASSPHRASE
	unset _SIGN_KEY
	unset PASSPHRASE
	unset _PASSPHRASE
    exit -1
fi

####################################
### Backup action
####################################
_PAUSE=1
printf "What do you want to do?\nbackup | check | restore\n"
sleep 3
read first_answer
case $first_answer in
	backup)
    echo "BACKUP"
    sleep $_PAUSE
    echo -e "What kind of backup do you want to create?\ninc | full | archive"
    _TMP=$_DEST"tmp"
    echo "BACKUP from $_SRC to $_TMP"
    sleep $_PAUSE
    read second_answer
    sleep $_PAUSE
    case $second_answer in
        ## ssh-backend pexpect --use-scp
        inc)
        # update current backup in tmp, do not create archive file
        duplicity inc --gpg-options "--compress-algo bzip2 --cipher-algo aes256 --digest-algo sha512 --s2k-digest-algo sha512 --s2k-cipher-algo aes256" --sign-key "$_SIGN_KEY" --exclude "**excludeFromBackup/**" --exclude "**safe/**" --log-file $_LOG --volsize 250 --verbosity 6 $_SRC "file://$_TMP"
    	;;
    	full)
        # create new full backup in tmp, create archive file with time stamp
        duplicity full --gpg-options "--compress-algo bzip2 --cipher-algo aes256 --digest-algo sha512 --s2k-digest-algo sha512 --s2k-cipher-algo aes256" --sign-key "$_SIGN_KEY" --exclude "**excludeFromBackup/**" --exclude "**safe/**" --log-file $_LOG --volsize 250 --verbosity 6 $_SRC "file://$_TMP"
        _FILE="$_DEST$_TIMESTAMP-backup.tar.gz"
        sleep $_PAUSE
        printf "Creating encrypted archive in $_FILE\n"
        cd $_DEST
        tar -czvpf $_FILE tmp/
    	;;
        # create archive file from backup in tmp
        archive)
        ## check directory exists
        if [ ! -d "$_TMP" ]; then
            printf "$_TMP DIRECTORY DOES NOT EXIST"
            exit -1
        fi
        _FILE="$_DEST$_TIMESTAMP-backup.tar.gz"
        sleep $_PAUSE
        printf "Creating encrypted archive in $_FILE\n"
        cd $_DEST
        tar -czvpf $_FILE tmp/
        ;;
        *) echo "not an option" && exit -1;;
    esac
	;;
    check)
    echo "CHECK"
    sleep $_PAUSE
    printf "What kind of check do you want to have?\nverify | list\n"
    _TMP=$_DEST"tmp"
    echo "CHECK BACKUP from $_SRC to $_TMP"
    sleep $_PAUSE
    read second_answer
    case $second_answer in
        verify)
        duplicity verify -v4 --sign-key "$_SIGN_KEY" --exclude "**excludeFromBackup/**" "file://$_TMP" $_SRC
    	;;
    	list)
        duplicity list-current-files --sign-key "$_SIGN_KEY" "file://$_TMP"
    	;;
        *) echo "not an option" && exit -1;;
    esac
    ;;
    restore)
    echo "RESTORE"
    _TMP=$_DEST"tmp"
    echo $_TMP
    echo $_RESTORE
    duplicity --sign-key "$_SIGN_KEY" file://$_TMP $_RESTORE;;
    #esac
    #;;
*) echo "not an option" && exit -1;;
esac


####################################
### Reset everything
####################################
unset _SALT
unset _HASH
unset _MYHASH
unset SIGN_PASSPHRASE
unset _SIGN_KEY
unset PASSPHRASE
unset _PASSPHRASE
exit 1
