#!/bin/sh
#
# Claude Code — install binary + link/merge configuration
#
# Backs up existing files/directories to $DOTFILES_BACKUP_DIR or ~/.claude/*.backup

# Install claude binary if not present. DOTFILES_LINK_ONLY (set by script/link)
# skips this and only links config.
if [ -z "$DOTFILES_LINK_ONLY" ] && ! command -v claude > /dev/null 2>&1; then
    echo "  Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

DOTFILES_CLAUDE="$HOME/.dotfiles/claude"

backup_claude_item () {
    local item=$1
    if [ -n "$DOTFILES_BACKUP_DIR" ]; then
        bdir="$DOTFILES_BACKUP_DIR/$(basename "$(dirname "$item")" | sed 's/^\.//')"
        mkdir -p "$bdir"
        mv "$item" "$bdir/$(basename "$item")"
        echo "  Backed up $item to $bdir/"
    else
        mv "$item" "${item}.backup"
        echo "  Backed up $item to ${item}.backup"
    fi
}

# settings.json is a regular file per config dir, merged from two tracked layers:
#   claude/settings.json            shared keys: permissions, hooks, env, autoMode, ...
#   claude/accounts/<account>.json  seed for the account keys listed below
# Claude Code writes UI choices (/model, effort, /theme, /plugin) into the config
# dir's settings.json, and the two accounts do not see the same models, so those
# keys live per account rather than in one symlinked file. The merge keeps the
# account keys (and any key the UI added that the repo does not know) and
# refreshes the shared keys from the repo. A shared key changed through the UI
# therefore does not reach the repo: the merge reports the drift, backs the old
# file up and lets the repo win -- copy wanted changes into claude/settings.json.
ACCOUNT_KEYS='["model","effortLevel","modelSettings","theme","enabledPlugins","pluginConfigs"]'

merge_settings () {
    local shared=$1 seed=$2 dst=$3 cur tmp drift extra
    if ! command -v jq > /dev/null 2>&1; then
        echo "  WARNING: jq not found; $dst left as is"
        return
    fi
    if [ -L "$dst" ]; then
        # Old layout: a symlink to the shared file, whose account keys are the
        # personal ones. Start every account from its seed instead.
        rm "$dst"
        cur=$seed
    elif [ -f "$dst" ]; then
        cur=$dst
    else
        cur=$seed
    fi
    # Shared keys minus the account keys, then every key of the current file
    # that the shared layer does not define.
    tmp=$(mktemp)
    jq -n --argjson keys "$ACCOUNT_KEYS" --slurpfile shared "$shared" --slurpfile cur "$cur" '
        ($shared[0] | with_entries(select(.key as $k | $keys | index($k) | not))) as $s
        | $s + (($cur[0] // {}) | with_entries(select(.key as $k | $s | has($k) | not)))' > "$tmp" || { rm -f "$tmp"; return 1; }
    drift=$(jq -r -n --argjson keys "$ACCOUNT_KEYS" --slurpfile shared "$shared" --slurpfile cur "$cur" '
        ($shared[0] | with_entries(select(.key as $k | $keys | index($k) | not))) as $s
        | [($cur[0] // {}) | to_entries[] | select(.key as $k | ($s | has($k)) and ($s[$k] != .value)) | .key] | join(" ")')
    extra=$(jq -r -n --argjson keys "$ACCOUNT_KEYS" --slurpfile shared "$shared" --slurpfile cur "$cur" '
        ($shared[0] | with_entries(select(.key as $k | $keys | index($k) | not))) as $s
        | [($cur[0] // {}) | to_entries[] | select(.key as $k | ($s | has($k) | not) and (($keys | index($k)) | not)) | .key] | join(" ")')
    if [ -n "$drift" ]; then
        echo "  $dst differs from $shared in: $drift (repo wins; edit claude/settings.json to keep them)"
        [ "$cur" = "$dst" ] && backup_claude_item "$dst"
    fi
    [ -n "$extra" ] && echo "  $dst keeps keys the repo does not have: $extra"
    mv "$tmp" "$dst"
    chmod 600 "$dst"
    echo "  Merged $shared + $seed -> $dst"
}

# One config dir per account: ~/.claude (personal) and ~/.claude-work (work,
# used by the `claude-work` wrapper via CLAUDE_CONFIG_DIR). Both get the same
# tracked config; logins, history, memory and the account keys of settings.json
# stay separate.
for entry in "$HOME/.claude:personal" "$HOME/.claude-work:work"; do
    CLAUDE_DIR=${entry%:*}
    ACCOUNT=${entry##*:}
    mkdir -p "$CLAUDE_DIR"

    merge_settings "$DOTFILES_CLAUDE/settings.json" "$DOTFILES_CLAUDE/accounts/$ACCOUNT.json" "$CLAUDE_DIR/settings.json"

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

    # Symlink directories (commands, agents, skills, themes)
    for dir in commands agents skills themes; do
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
done

# Print the diff a sudo install applies: installed copy (or nothing) -> tracked copy
show_install_diff () {
    if [ -e "$2" ]; then diff -u "$2" "$1"; else diff -u /dev/null "$1"; fi | sed 's/^/    /'
}

# macOS: sandbox Bash and confine the file tools to the project directory via
# managed settings. Copied, not linked: a broken managed-settings.json stops
# Claude Code from starting, so only a copy that parses is installed.
if [ "$(uname -s)" = Darwin ]; then
    gitcfg_src="$HOME/.dotfiles/git/gitconfig.sandbox"
    gitcfg_dst="/Library/Application Support/ClaudeCode/gitconfig"
    if ! cmp -s "$gitcfg_src" "$gitcfg_dst"; then
        echo "  Installing $gitcfg_src -> $gitcfg_dst (sudo)"
        show_install_diff "$gitcfg_src" "$gitcfg_dst"
        { sudo mkdir -p "$(dirname "$gitcfg_dst")" && sudo cp "$gitcfg_src" "$gitcfg_dst"; } ||
            echo "  WARNING: could not install $gitcfg_dst; git fails inside the sandbox"
    fi

    managed_src="$DOTFILES_CLAUDE/managed-settings.macos.json"
    managed_dst="/Library/Application Support/ClaudeCode/managed-settings.json"
    if ! /usr/bin/plutil -convert xml1 -o /dev/null "$managed_src" 2>/dev/null; then
        echo "  WARNING: $managed_src does not parse; managed settings not installed"
    elif ! cmp -s "$managed_src" "$managed_dst"; then
        echo "  Installing $managed_src -> $managed_dst (sudo)"
        show_install_diff "$managed_src" "$managed_dst"
        { sudo mkdir -p "$(dirname "$managed_dst")" &&
          { [ ! -e "$managed_dst" ] || [ -e "$managed_dst.backup" ] || sudo cp "$managed_dst" "$managed_dst.backup"; } &&
          sudo cp "$managed_src" "$managed_dst"; } ||
            echo "  WARNING: could not install $managed_dst; Claude Code is not sandboxed"
    fi
fi
