#!/bin/bash
#
# Tmux Plugin Manager (TPM) and the plugins in tmux.conf

set -e

if ! command -v tmux >/dev/null 2>&1; then
  echo "  tmux: not installed"
  exit 1
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Install plugins headlessly
"$TPM_DIR/bin/install_plugins"
