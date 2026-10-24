#!/bin/sh
#
# pixi (conda-forge package manager)

if [ -x "$HOME/.pixi/bin/pixi" ]; then
  # The NFS home is shared across architectures; leave another host's pixi in place
  if "$HOME/.pixi/bin/pixi" --version >/dev/null 2>&1; then
    echo "  pixi: already installed"
  else
    echo "  pixi: $HOME/.pixi/bin/pixi does not run on $(uname -m), skipping"
  fi
  exit 0
fi

echo "  pixi: installing"
# Shell rc files are symlinks into this repo; PATH comes from profile.symlink
curl -fsSL https://pixi.sh/install.sh | PIXI_NO_PATH_UPDATE=1 bash

# The pipeline's status is bash's, which hides a failed download
"$HOME/.pixi/bin/pixi" --version
