#!/bin/sh
#
# Rust (via rustup) and the cargo-installed tools

set -e

if [ -f "$HOME/.cargo/env" ]; then
    echo "  Rust already installed, updating..."
    . "$HOME/.cargo/env"
    rustup update
else
    echo "  Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
fi

# Vendored OpenSSL: hosts without pkg-config or OpenSSL headers can't build it
# otherwise. The config entry keeps the feature when install-update rebuilds it.
cargo install --locked cargo-update --features vendored-openssl
cargo install-update-config cargo-update --feature vendored-openssl
cargo install --locked zoxide bat fd-find eza git-delta
cargo install --locked skim --no-default-features --features cli

# skim shell integration (key-bindings for Ctrl-R, etc.) from the release
# matching sk. With the vim plugin, ~/.skim is vim-plug's clone of skim, which
# already has the file; writing into it would leave the clone dirty and break
# PlugUpdate.
if [ -d "$HOME/.skim/.git" ]; then
    echo "  skim key-bindings: provided by the vim plugin's clone in ~/.skim"
else
    version=$(sk --version | awk '{ print $2 }')
    mkdir -p "$HOME/.skim/shell"
    curl -fsSL -o "$HOME/.skim/shell/key-bindings.bash" \
      "https://raw.githubusercontent.com/skim-rs/skim/v$version/shell/key-bindings.bash"
fi
