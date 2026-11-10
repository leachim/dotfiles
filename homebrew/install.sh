#!/bin/sh
#
# Homebrew and the packages in the Brewfile

set -e

# A fresh install is not on PATH yet
if ! command -v brew >/dev/null 2>&1; then
  echo "  Installing Homebrew for you."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew" ]; then
      eval "$("$brew" shellenv)"
      break
    fi
  done
fi

brew update
brew bundle --file="$HOME/.Brewfile" --verbose
