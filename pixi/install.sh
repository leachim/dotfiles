#!/bin/sh
#
# pixi (conda-forge package manager)

if [ -x "$HOME/.pixi/bin/pixi" ]; then
  echo "  pixi: already installed"
else
  echo "  pixi: installing"
  # Shell rc files are symlinks into this repo; PATH comes from pixi/path.zsh and bashrc
  curl -fsSL https://pixi.sh/install.sh | PIXI_NO_PATH_UPDATE=1 bash
fi

exit 0
