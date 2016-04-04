#!/usr/bin/env bash

## Intro
echo "Install basic environment, no root access required"
sleep 2
echo "The following packages should be installed: vim git zsh curl (conky + exuberant-ctags)"
echo "exuberant-ctags is needed for special vim plugin"
sleep 10

# sudo apt-get install vim git zsh curl conky exuberant-ctags
function link_file {
	source="${PWD}/$1"
    target="${HOME}/${1/_/.}"

    if [ -e "${target}" ] && [ ! -L "${target}" ]; then
		echo "Renaming $target to $target.bak"
        mv $target $target.bak
    fi

    if [ ! -e "${target}" ]; then
        echo "Linking $source to $target"
        ln -sf ${source} ${target}
    fi
}


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
#dir="$HOME/.dotfiles/common"

for dotfile in  _* ;
do
	link_file $dotfile
done
sleep 5


##
echo "Installing Vim Plugins .."
vim +BundleInstall +qall

## echo "Remember to remove git alias file in zprezto"
