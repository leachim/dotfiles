#!/bin/bash

# sudo apt-get install vim git zsh curl conky exuberant-ctags

## Intro
echo "Install basic command line environment"
sleep 2
echo "The following packages should be installed: vim git zsh curl (conky)"
hash git 2>/dev/null || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
hash vim 2>/dev/null || { echo >&2 "I require vim but it's not installed.  Aborting."; exit 1; }
hash curl 2>/dev/null || { echo >&2 "I require curl but it's not installed.  Aborting."; exit 1; }

##
echo "symlinking dotfiles..."
dir="$HOME/.dotfiles/common"

#
echo "backing up existing dotfiles..."
for dotfile in ${HOME}/.*; 
do 
  echo "backup up $dotfile"
  mv $dotfile "$dotfile.bak"
done
sleep 3

for dotfile in  .* ;
do
	echo "creating symlik for $dotfile"
    if [ -d $dotfile ]; then
        ln -sf "$dir/$dotfile/" "$HOME/$dotfile"
    else
	    ln -sf "$dir/$dotfile" "$HOME/$dotfile"
    fi
done
sleep 5

##
echo "Installing Vim Plugins .."
vim +BundleInstall +qall

##
echo "Configuring ZSH and Prezto .."
##
hash foo 2>/dev/null || { echo >&2 "I require foo but it's not installed.  Aborting."; exit 1; }

zsh -c 'setopt EXTENDED_GLOB;
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done'

# set zsh as default shell
echo "Run command to switch default shell to zsh: \nchsh -s /bin/zsh"
