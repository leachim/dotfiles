#!/bin/sh
#
# pi coding agent — install binary + link instructions and permission guard
#
# pi reads its global config from ~/.pi/agent. Global instructions (AGENTS.md)
# are linked to claude/CLAUDE.md so the personality and safety rules stay in one
# place across tools. pi has no permission system, so extensions/guard.ts
# restates the rules the other agents enforce. pi has no sandbox either, so it
# is not installed on macOS.
#
# Backs up existing files to $BACKUP_DIR or ~/.pi/agent/*.backup

if [ "$(uname -s)" = Darwin ]; then
    echo "  pi: not supported on macOS -- it has no sandbox to confine writes to the working directory. Skipping."
    exit 0
fi

PI_DIR="$HOME/.pi/agent"
DOTFILES_PI="$HOME/.dotfiles/pi"

# The installer's managed layout keeps its release under ~/.pi/agent/install;
# `command -v pi` could match an unrelated pi. It runs without a terminal
# (setsid) so it neither offers to edit the shell rc files, which are tracked
# here, nor starts pi when done. The pi() wrapper finds the binary in
# ~/.pi/agent/bin or ~/.local/bin, so PATH needs no change.
if [ ! -d "$PI_DIR/install" ]; then
    echo "  Installing pi..."
    installer=$(mktemp)
    curl -fsSL https://pi.dev/install.sh -o "$installer" &&
        setsid sh "$installer" < /dev/null
    rm -f "$installer"
fi

link_pi () {
    src=$1
    dst=$2

    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        if [ -n "$BACKUP_DIR" ]; then
            mkdir -p "$BACKUP_DIR/pi"
            mv "$dst" "$BACKUP_DIR/pi/$(basename "$dst")"
            echo "  Backed up $dst to $BACKUP_DIR/pi/"
        else
            mv "$dst" "$dst.backup"
            echo "  Backed up $dst to $dst.backup"
        fi
    fi

    ln -s "$src" "$dst"
    echo "  Linked $src -> $dst"
}

link_pi "$HOME/.dotfiles/claude/CLAUDE.md" "$PI_DIR/AGENTS.md"
link_pi "$DOTFILES_PI/extensions/guard.ts" "$PI_DIR/extensions/guard.ts"
