#!/bin/bash

## Packages that should be installed
# i3, rofi, urxvt256colors, colordiff

## Install keys for the packages
echo "Installing keys for the hopefully updated packages in /etc/apt/sources.list"
sleep 10
echo "virtualbox"
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
echo "dropbox"
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
echo "tor"
gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
echo "docker official"
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
echo "google cloud"
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "google chrome on debian"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -


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

sleep 3
cat packages-debian | grep -v -e '^$' | grep -v \# | xargs sudo apt-get install -y
sleep 10

## Setup urxvt
echo "Setting urxvt as default terminal emulator .."
sudo update-alternatives --set x-terminal-emulator /usr/bin/urxvt

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
echo "Please manually install python and docker packages"
sleep 5

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
