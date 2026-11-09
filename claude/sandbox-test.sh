#!/bin/bash
#
# Claude Code sandbox test -- probes the boundary claude/managed-settings.macos.json
# and bin/claude-write-guard describe.
#
# Claude's sandbox wraps each Bash command of a session, so this runs inside a
# session: ask Claude to run ./claude/sandbox-test.sh, or start it from the
# Bash tool yourself. In a plain terminal nothing is sandboxed and the script
# stops. Bash probes run as plain commands and classify by error text, because
# a denied path fails the existence check exactly like a missing one. The file
# tools (Read, Edit, Write, Grep, Glob) bypass the sandbox and are confined by
# the PreToolUse hook instead, so that hook is fed synthetic tool calls.
#
#   ./claude/sandbox-test.sh      (from inside a Claude Code session)

set -u

if [ -z "${CLAUDE_CODE_ENTRYPOINT:-}" ]; then
    echo "not inside a Claude Code session: nothing is sandboxed here"
    exit 2
fi

managed='/Library/Application Support/ClaudeCode/managed-settings.json'
repo=$(cd "$(dirname "$0")/.." && pwd)
guard="$repo/bin/claude-write-guard"
fails=0

pass () { printf 'PASS  %-36s %s\n' "$1" "$2"; }
fail () { printf 'FAIL  %-36s %s\n' "$1" "$2"; fails=$((fails + 1)); }

# probe <ok|denied> <label> <command>
# Exit 0 is ok; "not permitted" in stderr is the sandbox; "no such file" means
# the path does not exist on this machine and the probe is skipped.
probe () {
    local expect=$1 label=$2 err rc got
    shift 2
    err=$(/bin/sh -c "$*" 2>&1 > /dev/null); rc=$?
    if [ $rc -eq 0 ]; then
        got=ok
    elif printf '%s' "$err" | grep -qi 'not permitted'; then
        got=denied
    elif printf '%s' "$err" | grep -qi 'no such file'; then
        printf 'SKIP  %-36s (does not exist)\n' "$label"
        return
    else
        got="failed: $(printf '%s' "$err" | head -1 | cut -c1-60)"
    fi
    if [ "$got" = "$expect" ]; then pass "$label" "$got"; else fail "$label" "expected $expect, got $got"; fi
}

# guard <allowed|blocked> <tool> <path>
# Feeds the PreToolUse hook the JSON Claude Code would send for that tool call.
guard () {
    local expect=$1 tool=$2 path=$3 key=file_path rc got
    [ "$tool" = Grep ] || [ "$tool" = Glob ] && key=path
    printf '{"tool_name":"%s","cwd":"%s","tool_input":{"%s":"%s"}}' "$tool" "$PWD" "$key" "$path" |
        /bin/bash "$guard" > /dev/null 2>&1
    rc=$?
    case $rc in 0) got=allowed ;; 2) got=blocked ;; *) got="exit $rc" ;; esac
    if [ "$got" = "$expect" ]; then pass "$tool $path" "$got"; else fail "$tool $path" "expected $expect, got $got"; fi
}

echo "claude $(claude --version 2> /dev/null | head -1) · workspace $PWD"
echo
echo "## managed settings ($managed)"
if [ ! -f "$managed" ]; then
    fail "managed settings installed" "missing: run claude/install.sh"
else
    if cmp -s "$managed" "$repo/claude/managed-settings.macos.json"; then
        pass "managed settings installed" "match repo"
    else
        fail "managed settings installed" "differ from repo: run claude/install.sh"
    fi
    setting () {
        local key=$1 want=$2 got
        got=$(/usr/bin/plutil -extract "$key" raw -o - "$managed" 2> /dev/null)
        if [ "$got" = "$want" ]; then pass "$key" "$got"; else fail "$key" "expected $want, got ${got:-unset}"; fi
    }
    setting sandbox.enabled true
    setting sandbox.failIfUnavailable true
    setting sandbox.allowUnsandboxedCommands false
    setting sandbox.filesystem.denyRead.0 '~'
    setting sandbox.network.allowedDomains.0 '*'
    if /usr/bin/plutil -extract hooks.PreToolUse.0.hooks.0.command raw -o - "$managed" 2> /dev/null | grep -q claude-write-guard && [ -r "$guard" ]; then
        pass "file-tool guard wired and present" ok
    else
        fail "file-tool guard wired and present" "hook or $guard missing"
    fi
fi
echo
echo "## Bash writes"
probe denied "write \$HOME"              'echo x > ~/claude-sandbox-test.$$'
probe ok     "write workspace"           'echo x > ./.claude-sandbox-test.$$ && rm ./.claude-sandbox-test.$$'
probe ok     "write \$TMPDIR"            'echo x > "$TMPDIR/claude-sandbox-test.$$" && rm "$TMPDIR/claude-sandbox-test.$$"'
# Scratch repository for the git probes. Set up without the global config so
# the write probes below do not depend on git being able to read it.
ws=$(mktemp -d "${TMPDIR:-/tmp}/claude-sandbox-test.XXXXXX") || exit 1
trap 'rm -rf "$ws"' EXIT
GIT_CONFIG_GLOBAL=/dev/null git init -q "$ws" || exit 1
probe ok     "git commit in \$TMPDIR"    "cd '$ws' && git -c user.name=t -c user.email=t@t commit -q --allow-empty -m t"
# Hooks and .git/config run code outside the sandbox; the file-tool guard
# blocks them, and so does the codex profile for shell commands.
probe denied "write .git/hooks"          "cd '$ws' && echo x > .git/hooks/claude-sandbox-test"
probe denied "write .git/config"         "cd '$ws' && GIT_CONFIG_GLOBAL=/dev/null git config probe.key value"
echo
echo "## Bash reads outside \$HOME"
probe ok     "read /etc/hosts"           'cat /etc/hosts'
probe denied "read /Volumes"             'ls /Volumes'
echo
echo "## Bash reads inside \$HOME"
probe ok     "read ~/.bun"               'ls ~/.bun'
probe ok     "read ~/.config/gh"         'ls ~/.config/gh'
probe ok     "read ~/.dotfiles/bin"      'ls ~/.dotfiles/bin'
probe ok     "read ~/.secrets/pushover"  'cat ~/.secrets/pushover'
probe ok     "git reads its global config" 'git config init.defaultBranch'
probe denied "read ~/.secrets"           'ls ~/.secrets'
probe denied "read ~/.ssh"               'ls ~/.ssh'
probe denied "read ~/.codex/auth.json"   'cat ~/.codex/auth.json'
probe denied "read ~/.zshrc"             'cat ~/.zshrc'
probe denied "read ~/Documents"          'ls ~/Documents'
probe denied "read ~/Library/Safari"     'ls ~/Library/Safari'
probe denied "read ~/.local/share/opencode" 'ls ~/.local/share/opencode'
probe denied "read ~/.cache/huggingface" 'ls ~/.cache/huggingface'
echo
echo "## network"
probe ok     "https to github.com"       'curl -sSf -o /dev/null --max-time 20 https://github.com'
echo
echo "## file-tool guard (bin/claude-write-guard)"
if [ -r "$guard" ]; then
    guard allowed Write "$PWD/claude-sandbox-test.tmp"
    guard allowed Write "${TMPDIR:-/tmp}/claude-sandbox-test.tmp"
    guard blocked Write "$HOME/claude-sandbox-test.tmp"
    guard blocked Write "$PWD/.git/hooks/claude-sandbox-test"
    guard blocked Write "$PWD/.git/config"
    guard blocked Write "$HOME/.zshrc"
    guard allowed Read  /etc/hosts
    guard allowed Read  "$HOME/.bun/package.json"
    guard allowed Read  "$HOME/.secrets/pushover"
    guard blocked Read  "$HOME/.secrets/github"
    guard blocked Read  "$HOME/.ssh/config"
    guard blocked Read  "$HOME/Documents/x"
    guard blocked Grep  "$HOME"
    guard blocked Grep  /Volumes
else
    fail "file-tool guard" "$guard is not readable"
fi
echo
if [ "$fails" -eq 0 ]; then echo "all probes passed"; else echo "$fails probe(s) failed"; fi
exit $(( fails > 0 ))
