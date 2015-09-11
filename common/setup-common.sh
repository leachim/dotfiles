#!/bin/bash

## Intro
echo "Install basic environment, no root access required"
sleep 2
echo "The following packages should be installed: vim git zsh curl (conky + exuberant-ctags)"
echo "exuberant-ctags is needed for special vim plugin"
sleep 10

# sudo apt-get install vim git zsh curl conky exuberant-ctags


##
echo "Configuring ZSH and Prezto .."
##
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
zsh -c 'setopt EXTENDED_GLOB;
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done'
echo "ENTER USER PASSWORD"

# set zsh as default shell
chsh -s /bin/zsh

rm $HOME/.zlogout
echo "Remove .zlogout, no sensible message included"


##
echo "Pimping Vim .."
git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle


##
echo "symlinking dotfiles..."
dir="$HOME/.dotfiles/common"

for dotfile in  .* ;
do
	echo "creating symblik for $dotfile"
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
