#!/bin/bash
#
# Codex sandbox check -- probes the boundary codex/config.toml describes.
#
# Each probe runs a shell command under `codex sandbox` from a scratch git
# repository and compares the outcome with what the confined profile promises.
# Run it from a normal terminal after codex/install.sh: seatbelt does not nest,
# so it cannot run from inside Claude Code's sandbox.
#
#   ./codex/sandbox-check.sh

set -u

ws=$(mktemp -d)
trap 'rm -rf "$ws"' EXIT
cd "$ws" || exit 1
git init -q . || exit 1

fails=0

# probe <ok|denied> <label> <path that must exist, or -> <command>
# A probe whose precondition path is missing is skipped: `ls` on a missing
# directory fails whether or not the sandbox denies it.
probe () {
    local expect=$1 label=$2 need=$3 got
    shift 3
    if [ "$need" != - ] && [ ! -e "${need/#\~/$HOME}" ]; then
        printf 'SKIP  %-28s (%s does not exist)\n' "$label" "$need"
        return
    fi
    if codex sandbox -- /bin/sh -c "$*" > /dev/null 2>&1; then got=ok; else got=denied; fi
    if [ "$got" = "$expect" ]; then
        printf 'PASS  %-28s %s\n' "$label" "$got"
    else
        printf 'FAIL  %-28s expected %s, got %s\n' "$label" "$expect" "$got"
        fails=$((fails + 1))
    fi
}

echo "codex $(codex --version 2> /dev/null | tail -1) · workspace $ws"
echo
echo "## effective sandbox (codex doctor)"
codex doctor 2> /dev/null | sed -n '/^  . sandbox /,/^  . sandbox .*probe/p'
echo
echo "## writes"
probe ok     "write workspace"           -                 'echo x > probe'
probe ok     "write \$TMPDIR"            -                 'echo x > "${TMPDIR:-/tmp}/codex-sandbox-check.$$" && rm -f "${TMPDIR:-/tmp}/codex-sandbox-check.$$"'
probe denied "write \$HOME"              -                 'echo x > ~/codex-sandbox-check.$$'
probe ok     "git commit in workspace"   -                 'git -c user.name=t -c user.email=t@t commit -q --allow-empty -m t'
probe denied "write .git/hooks"          -                 'echo x > .git/hooks/codex-sandbox-check'
probe denied "write .git/config"         -                 'git config probe.key value'
echo
echo "## reads outside \$HOME"
probe ok     "read /etc/hosts"           -                 'cat /etc/hosts'
probe denied "read /Volumes"             /Volumes          'ls /Volumes'
echo
echo "## reads inside \$HOME"
probe ok     "read ~/.bun"               ~/.bun            'ls ~/.bun'
probe ok     "read ~/.config/gh"         ~/.config/gh      'ls ~/.config/gh'
probe ok     "read ~/.gitconfig"         ~/.gitconfig      'cat ~/.gitconfig'
probe denied "read ~/.secrets"           ~/.secrets        'ls ~/.secrets'
probe denied "read ~/.ssh"               ~/.ssh            'ls ~/.ssh'
probe denied "read ~/.codex/auth.json"   ~/.codex/auth.json 'cat ~/.codex/auth.json'
probe denied "read ~/.zshrc"             ~/.zshrc          'cat ~/.zshrc'
probe denied "read ~/Documents"          ~/Documents       'ls ~/Documents'
probe denied "read ~/.cache/huggingface" ~/.cache/huggingface 'ls ~/.cache/huggingface'
probe denied "read ~/.dotfiles/zsh"      ~/.dotfiles/zsh   'ls ~/.dotfiles/zsh'
probe ok     "read ~/.dotfiles/bin"      ~/.dotfiles/bin   'ls ~/.dotfiles/bin'
echo
echo "## network"
probe ok     "https to github.com"       -                 'curl -sSf -o /dev/null --max-time 20 https://github.com'
echo
echo "## requirements (/etc/codex/requirements.toml)"
if [ ! -f /etc/codex/requirements.toml ]; then
    echo "FAIL  requirements file missing: run codex/install.sh"
    fails=$((fails + 1))
else
    for o in 'default_permissions=":danger-full-access"' 'sandbox_mode="danger-full-access"' 'approval_policy="on-request"'; do
        if codex doctor -c "$o" 2> /dev/null | grep -q 'disallowed by requirements'; then
            printf 'PASS  %-28s rejected\n' "-c $o"
        else
            printf 'FAIL  %-28s accepted\n' "-c $o"
            fails=$((fails + 1))
        fi
    done
fi
echo
if [ "$fails" -eq 0 ]; then echo "all probes passed"; else echo "$fails probe(s) failed"; fi
exit $(( fails > 0 ))
