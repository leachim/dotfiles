#!/bin/sh
#
# Codex CLI — symlink safe global configuration
#
# Backs up existing files/directories to $DOTFILES_BACKUP_DIR or ~/.codex/*.backup

CODEX_DIR="$HOME/.codex"
DOTFILES_CODEX="$HOME/.dotfiles/codex"

mkdir -p "$CODEX_DIR"

backup_codex_item () {
    local item=$1
    if [ -n "$DOTFILES_BACKUP_DIR" ]; then
        mkdir -p "$DOTFILES_BACKUP_DIR/codex"
        mv "$item" "$DOTFILES_BACKUP_DIR/codex/$(basename "$item")"
        echo "  Backed up $item to $DOTFILES_BACKUP_DIR/codex/"
    else
        mv "$item" "${item}.backup"
        echo "  Backed up $item to ${item}.backup"
    fi
}

# One config per platform: macOS keeps the sandbox profile in the root-owned
# requirements file installed below, Linux hosts carry it in config.linux.toml.
if [ "$(uname -s)" = Darwin ]; then cfg=config.toml; else cfg=config.linux.toml; fi
src="$DOTFILES_CODEX/$cfg"
dst="$CODEX_DIR/config.toml"
if [ -f "$src" ]; then
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ]; then
        backup_codex_item "$dst"
    fi
    ln -s "$src" "$dst"
    echo "  Linked $src -> $dst"
fi

# macOS: the sandbox profile, the choice of profile and approval policy, and
# the credential deny list, pinned for every launch path (CLI flags, --yolo,
# desktop app) via managed requirements. A requirements file codex cannot load
# stops every launch, so the install is checked and undone if codex rejects it.
if [ "$(uname -s)" = Darwin ]; then
    req_src="$DOTFILES_CODEX/requirements.macos.toml"
    req_dst=/etc/codex/requirements.toml
    if ! cmp -s "$req_src" "$req_dst"; then
        echo "  Installing $req_src -> $req_dst (sudo)"
        if { sudo mkdir -p /etc/codex &&
             { [ ! -e "$req_dst" ] || [ -e "$req_dst.backup" ] || sudo cp "$req_dst" "$req_dst.backup"; } &&
             sudo cp "$req_src" "$req_dst"; }; then
            if command -v codex > /dev/null 2>&1 && ! err=$(codex features list 2>&1 > /dev/null); then
                echo "  codex cannot load $req_dst; restoring the previous file:"
                printf '%s\n' "$err" | sed 's/^/    /'
                if [ -e "$req_dst.backup" ]; then sudo cp "$req_dst.backup" "$req_dst"; else sudo rm -f "$req_dst"; fi
                exit 1
            fi
        else
            echo "  WARNING: could not install $req_dst; codex may run unsandboxed"
        fi
    fi
fi
