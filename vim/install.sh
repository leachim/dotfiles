#!/bin/bash
#
# vim-plug and the plugins in vimrc, for vim and nvim

set -e

PLUG_URL=https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if ! command -v vim &> /dev/null && ! command -v nvim &> /dev/null; then
  echo "  vim: neither vim nor nvim is installed"
  exit 1
fi

if command -v vim &> /dev/null; then
  echo "  vim: installing plugins"
  curl -fsSLo ~/.vim/autoload/plug.vim --create-dirs "$PLUG_URL"
  vim -u "$HOME/.dotfiles/vim/vimrc.symlink" +PlugInstall +qall </dev/null &>/dev/null
  stty sane 2>/dev/null || true
fi

if command -v nvim &> /dev/null; then
  echo "  nvim: installing plugins"
  curl -fsSLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs "$PLUG_URL"
  nvim --headless -u "$HOME/.dotfiles/vim/vimrc.symlink" +PlugInstall +qall &>/dev/null
fi
