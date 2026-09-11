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

# Symlink files
for file in CLAUDE.md; do
    src="$DOTFILES_CLAUDE/$file"
    dst="$CLAUDE_DIR/$file"

    if [ ! -f "$src" ]; then
        continue
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

# settings.json is NOT symlinked. Claude Code owns that file -- /model, /effort,
# /config, plugin changes and the learned autoMode environment all rewrite it, and
# the rewrite is an atomic temp-file+rename that silently replaces a symlink with a
# regular file. (Evidence: CLAUDE.md, agents, skills and commands were all still
# symlinks here while settings.json was not, with no .backup beside it.)
#
# So dotfiles owns a SUBSET of keys instead. settings.base.json is authoritative for
# every top-level key it DECLARES; a key it does not declare is not owned and is
# left untouched (model, effortLevel, theme, enabledPlugins, the learned autoMode
# environment). To clear a key rather than leave it stale, declare it empty -- that
# is why "env" is {} here: AI_AGENT in it is dead (Claude Code sets its own, and
# claude() names it at launch) and CONTEXT7_API_KEY="${CONTEXT7_API}" is the
# literal-string bug b31aa2d documented; that one belongs in ~/.localrc.
merge_claude_settings () {
    src="$DOTFILES_CLAUDE/settings.base.json"
    dst="$CLAUDE_DIR/settings.json"

    [ -f "$src" ] || return 0
    if ! command -v jq > /dev/null 2>&1; then
        echo "  settings.base.json needs jq to merge -- skipped"
        return 0
    fi
    [ -f "$dst" ] || echo '{}' > "$dst"

    owned=$(jq -c 'keys' "$src")
    if jq -s --argjson owned "$owned" \
        '(.[0] | delpaths([$owned[] | [.]])) * .[1]' "$dst" "$src" > "$dst.tmp"; then
        mv "$dst.tmp" "$dst"
        echo "  Merged $(echo "$owned" | tr -d '[]"' ) into $dst"
    else
        rm -f "$dst.tmp"
        echo "  Failed to merge settings -- left $dst untouched"
    fi
}

merge_claude_settings
