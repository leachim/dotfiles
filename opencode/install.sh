#!/bin/sh
#
# opencode — install binary + symlink safe global configuration
#
# opencode reads its global config from $XDG_CONFIG_HOME/opencode (default
# ~/.config/opencode). Auth tokens live in ~/.local/share/opencode/auth.json
# and are intentionally NOT tracked.
#
# Global instructions (AGENTS.md) are linked to claude/CLAUDE.md so the
# personality and safety rules stay in one place across both tools.
#
# Backs up existing files/directories to $BACKUP_DIR or ~/.config/opencode/*.backup

if [ "$(uname -s)" = Darwin ]; then
    echo "  opencode: not supported on macOS -- it has no sandbox to confine writes to the working directory. Skipping."
    exit 0
fi

# Install opencode binary if not present
if ! command -v opencode > /dev/null 2>&1 && [ ! -x "$HOME/.opencode/bin/opencode" ]; then
    echo "  Installing opencode..."
    curl -fsSL https://opencode.ai/install | sh
fi

OPENCODE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
DOTFILES_OPENCODE="$HOME/.dotfiles/opencode"

mkdir -p "$OPENCODE_DIR"

backup_opencode_item () {
    item=$1
    if [ -n "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR/opencode"
        mv "$item" "$BACKUP_DIR/opencode/$(basename "$item")"
        echo "  Backed up $item to $BACKUP_DIR/opencode/"
    else
        mv "$item" "${item}.backup"
        echo "  Backed up $item to ${item}.backup"
    fi
}

# Link one path into $OPENCODE_DIR, backing up whatever is there first.
# Usage: link_opencode <source path> <destination name>
link_opencode () {
    src=$1
    dst="$OPENCODE_DIR/$2"

    if [ ! -e "$src" ]; then
        return
    fi

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        backup_opencode_item "$dst"
    fi

    ln -s "$src" "$dst"
    echo "  Linked $src -> $dst"
}

# Settings (track only stable, non-secret config)
for file in opencode.jsonc; do
    link_opencode "$DOTFILES_OPENCODE/$file" "$file"
done

# Global instructions — shared with Claude Code rather than duplicated
link_opencode "$HOME/.dotfiles/claude/CLAUDE.md" AGENTS.md

# Agent and command directories. Every *.md inside becomes an agent or a
# command named after the file, so keep documentation in opencode/README.md.
for dir in agent command; do
    link_opencode "$DOTFILES_OPENCODE/$dir" "$dir"
done
