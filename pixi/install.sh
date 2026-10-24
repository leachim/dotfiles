#!/bin/sh
#
# pixi (conda-forge package manager)

if [ -x "$HOME/.pixi/bin/pixi" ]; then
  echo "  pixi: already installed"
else
  echo "  pixi: installing"
  # Shell rc files are symlinks into this repo; PATH comes from profile.symlink
  curl -fsSL https://pixi.sh/install.sh | PIXI_NO_PATH_UPDATE=1 bash
fi

# The pipeline's status is bash's, which hides a failed download
"$HOME/.pixi/bin/pixi" --version
