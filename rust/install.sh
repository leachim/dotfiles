#!/bin/sh
#
# Rust (via rustup)

if [ -f "$HOME/.cargo/env" ]; then
    echo "  Rust already installed, updating..."
    . "$HOME/.cargo/env"
    rustup update
else
    echo "  Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
fi

cargo install --locked cargo-update zoxide bat fd-find eza git-delta
cargo install --locked skim --no-default-features --features cli

# Install skim shell integration (key-bindings for Ctrl-R, etc.)
mkdir -p "$HOME/.skim/shell"
curl -fLo "$HOME/.skim/shell/key-bindings.bash" \
  https://raw.githubusercontent.com/skim-rs/skim/master/shell/key-bindings.bash

exit 0
