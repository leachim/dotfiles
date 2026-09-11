#!/bin/sh
#
# Claude Code — install binary + symlink configuration
#
# Backs up existing files/directories to $BACKUP_DIR or ~/.claude/*.backup

# Install claude binary if not present
if ! command -v claude > /dev/null 2>&1; then
    echo "  Installing Claude Code CLI..."
    curl -fsSL https://cli.claude.ai/install.sh | sh
fi

CLAUDE_DIR="$HOME/.claude"
DOTFILES_CLAUDE="$HOME/.dotfiles/claude"

mkdir -p "$CLAUDE_DIR"

backup_claude_item () {
    local item=$1
    if [ -n "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR/claude"
        mv "$item" "$BACKUP_DIR/claude/$(basename "$item")"
        echo "  Backed up $item to $BACKUP_DIR/claude/"
    else
        mv "$item" "${item}.backup"
        echo "  Backed up $item to ${item}.backup"
    fi
}

# settings.json is symlinked, so UI changes land in the repo and show up in
# `git diff`. The whole file is tracked, machine-specific keys included (model,
# effortLevel, theme, enabledPlugins, autoMode) -- expect those to churn between
# machines.
#
# Claude Code may rewrite settings.json with a temp-file+rename, replacing the
# symlink with a regular file. When that has happened, copy it back into the repo
# and re-link rather than backing it up and discarding it. Re-run this script to
# reattach.
absorb_and_link () {
    src=$1
    dst=$2
    if [ ! -L "$dst" ] && [ -f "$dst" ]; then
        cp "$dst" "$src"
        echo "  Absorbed $dst into $src (it had been replaced by a regular file)"
        rm "$dst"
    fi
}

# Symlink files
for file in CLAUDE.md settings.json; do
    src="$DOTFILES_CLAUDE/$file"
    dst="$CLAUDE_DIR/$file"

    if [ ! -f "$src" ]; then
        continue
    fi

    if [ "$file" = settings.json ]; then
        absorb_and_link "$src" "$dst"
    fi

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -f "$dst" ]; then
        backup_claude_item "$dst"
    fi

    ln -s "$src" "$dst"
    echo "  Linked $src -> $dst"
done

# Symlink directories (commands, agents, skills)
for dir in commands agents skills; do
    src="$DOTFILES_CLAUDE/$dir"
    dst="$CLAUDE_DIR/$dir"

    if [ ! -d "$src" ]; then
        continue
    fi

    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -d "$dst" ]; then
        backup_claude_item "$dst"
    fi

    ln -s "$src" "$dst"
    echo "  Linked $src -> $dst"
done
