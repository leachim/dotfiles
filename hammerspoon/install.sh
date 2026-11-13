#!/usr/bin/env bash
#
# Hammerspoon: link init.lua into ~/.hammerspoon. macOS only (the app comes
# from the Brewfile).

cd "$(dirname "$0")"/..
. script/lib.sh

[ "$(uname -s)" = Darwin ] || exit 0

mkdir -p "$HOME/.hammerspoon"
link_file "$DOTFILES_ROOT/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"
