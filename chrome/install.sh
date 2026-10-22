#!/usr/bin/env bash
#
# chrome-headless-shell (Chrome for Testing) in ~/.local/share/chrome-headless-shell,
# run through bin/chrome-headless-shell. Installs the current stable build and
# removes the older builds for this platform; script/update reruns it.

set -e

CHS_DIR="$HOME/.local/share/chrome-headless-shell"

# Chrome for Testing has no Linux arm64 build. The platform prefix keeps builds
# apart when the NFS home is shared across architectures.
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) platform=mac_arm ;;
  Darwin-x86_64) platform=mac ;;
  Linux-x86_64) platform=linux ;;
  *)
    echo "  chrome-headless-shell: no build for $(uname -s) $(uname -m), skipping"
    exit 0
    ;;
esac

if ! command -v bunx >/dev/null 2>&1; then
  echo "  chrome-headless-shell: needs bun (bun/install.sh)"
  exit 1
fi

# Downloads only if that build is missing
build=$(bunx @puppeteer/browsers@latest install chrome-headless-shell@stable --path "$CHS_DIR" --format '{{buildId}}')
if [ -z "$build" ] || [ ! -d "$CHS_DIR/chrome-headless-shell/$platform-$build" ]; then
  echo "  chrome-headless-shell: no $platform-$build in $CHS_DIR after install"
  exit 1
fi

for old in "$CHS_DIR/chrome-headless-shell/$platform"-*; do
  if [ "$old" != "$CHS_DIR/chrome-headless-shell/$platform-$build" ]; then
    echo "  chrome-headless-shell: removing ${old##*/}"
    rm -rf "$old"
  fi
done

echo "  chrome-headless-shell: $build"
