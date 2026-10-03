#!/bin/sh
#
# Codex CLI — symlink safe global configuration
#
# Backs up existing files/directories to $BACKUP_DIR or ~/.codex/*.backup

CODEX_DIR="$HOME/.codex"
DOTFILES_CODEX="$HOME/.dotfiles/codex"

mkdir -p "$CODEX_DIR"

backup_codex_item () {
    local item=$1
    if [ -n "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR/codex"
        mv "$item" "$BACKUP_DIR/codex/$(basename "$item")"
        echo "  Backed up $item to $BACKUP_DIR/codex/"
    else
        mv "$item" "${item}.backup"
        echo "  Backed up $item to ${item}.backup"
    fi
}

# Symlink files (track only stable, non-secret config)
for file in config.toml; do
    src="$DOTFILES_CODEX/$file"
    dst="$CODEX_DIR/$file"

    if [ ! -f "$src" ]; then
        continue
    fi

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ]; then
        backup_codex_item "$dst"
    fi

    ln -s "$src" "$dst"
    echo "  Linked $src -> $dst"
done

# macOS: forbid full-access sandbox modes for every launch path (CLI flags,
# desktop app), via managed requirements in a root-owned directory. Copied, not
# linked, so edits in this repo take effect on the next run of this script. A
# failed sudo only warns, so script/link carries on.
if [ "$(uname -s)" = Darwin ]; then
    req_src="$DOTFILES_CODEX/requirements.macos.toml"
    req_dst=/etc/codex/requirements.toml
    if ! cmp -s "$req_src" "$req_dst"; then
        echo "  Installing $req_src -> $req_dst (sudo)"
        { sudo mkdir -p /etc/codex &&
          { [ ! -e "$req_dst" ] || sudo cp "$req_dst" "$req_dst.backup"; } &&
          sudo cp "$req_src" "$req_dst"; } ||
            echo "  WARNING: could not install $req_dst; codex may run unsandboxed"
    fi
fi
