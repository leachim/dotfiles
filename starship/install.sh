#!/bin/sh
#
# starship

set -e

# Check if starship is already installed (e.g., via cargo)
if command -v starship >/dev/null 2>&1; then
  echo "  starship: already installed ($(starship --version | head -1))"
  exit 0
fi

if [ "$(uname -s)" = Darwin ]; then
  brew install starship
else
  echo "  starship: installing via official installer"
  # starship's installer exits 1 if --bin-dir does not already exist
  mkdir -p "$HOME/.local/bin"
  curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$HOME/.local/bin"
  # The pipeline's status is sh's, which hides a failed download
  "$HOME/.local/bin/starship" --version >/dev/null
fi
