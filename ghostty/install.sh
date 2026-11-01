#!/usr/bin/env bash
#
# Ghostty: link config.ghostty into ~/.config/ghostty. Skipped on hosts without
# Ghostty (the macOS app comes from the Brewfile).

cd "$(dirname "$0")"/..
. script/lib.sh

if [ "$(uname -s)" != Darwin ] && ! command -v ghostty >/dev/null 2>&1; then
  exit 0
fi

mkdir -p "$HOME/.config/ghostty"
link_file "$DOTFILES_ROOT/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
