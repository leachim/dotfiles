#!/bin/sh
#
# Bun runtime + global packages

# Check if bun is already installed
if command -v bun >/dev/null 2>&1; then
  echo "  bun: already installed ($(bun --version))"
else
  echo "  bun: installing"
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# Symlink bun as node so packages with #!/usr/bin/env node shebangs work, but
# only on hosts without a real node; ~/.bun/bin would otherwise shadow nvm's.
if [ ! -e "$HOME/.bun/bin/node" ] && ! command -v node >/dev/null 2>&1; then
  echo "  node: symlinking to bun"
  ln -s "$HOME/.bun/bin/bun" "$HOME/.bun/bin/node"
fi

# Global packages from packages.txt
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# bun finds its global root by walking up from the global dir to the nearest
# package.json; without one there it adopts ~/package.json and installs into ~
BUN_GLOBAL_DIR="${BUN_INSTALL_GLOBAL_DIR:-$HOME/.bun/install/global}"
mkdir -p "$BUN_GLOBAL_DIR"
[ -f "$BUN_GLOBAL_DIR/package.json" ] || echo '{}' > "$BUN_GLOBAL_DIR/package.json"
# Run global installs from $HOME to prevent bun's upward package.json
# traversal from walking into non-standard parent directories (e.g. /cluster/home/)
while IFS= read -r pkg || [ -n "$pkg" ]; do
  [ -z "$pkg" ] && continue
  echo "  $pkg: installing globally"
  (cd "$HOME" && bun install -g "$pkg")
done < "$SCRIPT_DIR/packages.txt"

exit 0
