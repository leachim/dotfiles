#!/bin/bash

## Install keys for the packages
echo "Installing keys for the hopefully updated packages in /etc/apt/sources.list"
sleep 10
echo "virtualbox"
sudo sh -c "wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- |  apt-key add -"
echo "dropbox"
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
echo "tor"
# Secure APT - gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
echo "x2go"
sudo apt-key adv --recv-keys --keyserver keys.gnupg.net E1F958385BFE2B6E
#echo "docker.io"
#sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
echo "docker official"
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D


## Install debian packages
echo "Installing Software .."
sudo apt-get update
#sudo apt-get upgrade -y
sleep 10
##
echo "Install the following debian packages from sources"
while read line
do
    if [[ $line == \#* ]]
    then
        echo $line
    fi
    if [[ -z $line ]]
    then
        continue
    fi
done < ./packages-debian

cat packages-debian | grep -v -e '^$' | grep -v \# | xargs sudo apt-get install -y
sleep 10
# install iceweasel from sid
#sudo apt-get install -t unstable iceweasel


## Setup urxvt
echo "Setting urxvt as default terminal emulator .."
sudo update-alternatives --set x-terminal-emulator /usr/bin/urxvt
# make urxvt use  ctrl-shift-c and v to copy and paste, need to have xsel +++ installed
sudo wget https://raw.githubusercontent.com/muennich/urxvt-perls/master/clipboard -O /usr/lib/urxvt/perl/clipboard
sleep 5


## symlink dotfiles
echo "symlinking dotfiles for desktop usage..."
dir="$HOME/.dotfiles/desktop"
sleep 5

rm -rf $HOME/.config
for dotfile in .*;
do
	echo "creating symlink for $dotfile"
    if [ -d $dotfile ]; then
        ln -sf "$dir/$dotfile/" "$HOME/$dotfile"
    else
	    ln -sf "$dir/$dotfile" "$HOME/$dotfile"
    fi
done


##
echo "Install R packages"
sleep 5
Rscript --vanilla packages-r --args "/home/michael"


##
echo "Install Python packages"
sleep 5

while read line
do
    if [[ $line == \#* ]]
    then
        echo $line
    else
        package=$line
        pip3 install "$package"
    fi
done < ./packages-python


## clean up
echo "clean up some files that may have been installed but are not needed"
sleep 3
sudo apt-get remove xfce4-notifyd
sudo apt-get remove openssh-server
sudo apt-get remove openssh-sftp-server


## sync configuration in /etc/
echo "sync configuration files in /etc/"
sleep 3
sudo rsync -a etc/* /etc/

## upgrade packages to testing
sudo apt-get update
sudo apt-get upgrade

## THE END
echo "Everything should be up and running! Best to reboot now"
sleep 5
