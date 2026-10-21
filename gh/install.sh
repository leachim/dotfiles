#!/usr/bin/env bash
#
# Install GitHub CLI (gh) on Linux using precompiled binaries.
# On macOS, gh is installed via Homebrew (Brewfile), so this is a no-op.
#
# With DOTFILES_UPGRADE (set by script/update) it instead replaces the gh in
# ~/.local/bin with the latest release, and installs nothing if there is none.

set -e

if [ "$(uname -s)" = "Darwin" ]; then
  echo "  gh: skipping (installed via Homebrew on macOS)"
  exit 0
fi

# Install location
GH_INSTALL_DIR="$HOME/.local"

if [ -n "$DOTFILES_UPGRADE" ]; then
  if [ ! -x "$GH_INSTALL_DIR/bin/gh" ]; then
    echo "  gh: not installed in $GH_INSTALL_DIR/bin, skipping"
    exit 0
  fi
  # The NFS home is shared across architectures; leave a gh built for another one
  if ! GH_CURRENT=$("$GH_INSTALL_DIR/bin/gh" --version 2>/dev/null); then
    echo "  gh: $GH_INSTALL_DIR/bin/gh does not run on $(uname -m), skipping"
    exit 0
  fi
  GH_CURRENT=$(echo "$GH_CURRENT" | awk 'NR == 1 { print $3 }')
elif command -v gh &> /dev/null; then
  echo "  gh: already installed"
  exit 0
fi

# Latest release, read from the redirect of releases/latest (no API rate limit)
GH_VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' https://github.com/cli/cli/releases/latest)
GH_VERSION=${GH_VERSION##*/v}
case "$GH_VERSION" in
  ''|*/*) echo "  gh: could not determine the latest release"; exit 1 ;;
esac

if [ "$GH_CURRENT" = "$GH_VERSION" ]; then
  echo "  gh: $GH_VERSION is the latest"
  exit 0
fi

echo "  gh: installing GitHub CLI $GH_VERSION for Linux (precompiled binary)"

ARCH=$(uname -m)

# Map architecture names
case "$ARCH" in
  x86_64)
    GH_ARCH="amd64"
    ;;
  aarch64)
    GH_ARCH="arm64"
    ;;
  *)
    echo "  gh: unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Download and extract
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "  gh: downloading gh_${GH_VERSION}_linux_${GH_ARCH}.tar.gz"
curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${GH_ARCH}.tar.gz" -o gh.tar.gz

echo "  gh: extracting to $GH_INSTALL_DIR"
tar -xzf gh.tar.gz
mkdir -p "$GH_INSTALL_DIR/bin"
cp "gh_${GH_VERSION}_linux_${GH_ARCH}/bin/gh" "$GH_INSTALL_DIR/bin/"
chmod +x "$GH_INSTALL_DIR/bin/gh"

# Optional: copy man pages and completions
if [ -d "$GH_INSTALL_DIR/share/man/man1" ]; then
  cp "gh_${GH_VERSION}_linux_${GH_ARCH}/share/man/man1/"* "$GH_INSTALL_DIR/share/man/man1/" 2>/dev/null || true
fi

# Cleanup
cd - > /dev/null
rm -rf "$TMP_DIR"

echo "  gh: installed $("$GH_INSTALL_DIR/bin/gh" --version | head -1)"
echo "  gh: make sure $GH_INSTALL_DIR/bin is in your PATH"
