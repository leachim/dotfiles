#!/bin/sh
#
# Oh My Zsh

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  Oh My Zsh already installed"
    exit 0
fi

# --keep-zshrc: don't overwrite existing .zshrc (our symlink)
# RUNZSH=no: don't launch zsh at end of install
RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc

# A failed download runs an empty script, which succeeds
[ -d "$HOME/.oh-my-zsh" ]
