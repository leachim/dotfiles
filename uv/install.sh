#!/bin/sh
#
# uv (standalone installer, into ~/.local/bin; script/update self-updates it)

if command -v uv >/dev/null 2>&1; then
  echo "  uv: already installed ($(uv --version))"
  exit 0
fi

echo "  uv: installing"
# Shell rc files are symlinks into this repo; PATH comes from profile.symlink
curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh

# The pipeline's status is sh's, which hides a failed download
"$HOME/.local/bin/uv" --version
