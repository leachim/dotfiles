#!/bin/sh
#
# Codex CLI — update the binary to the latest release
#
# The config in ~/.codex is managed by codex/install.sh and is untouched here.
# Detects how codex was installed and uses the matching package manager:
#   - npm global (nvm or system node): npm install -g @openai/codex@latest
#   - Homebrew (macOS):                brew upgrade codex
# Falls back to npm when codex is not installed yet.

set -e

before=$(codex --version 2>/dev/null || echo "not installed")
echo "  codex: $before"

bin=$(command -v codex 2>/dev/null || true)
real=$(readlink -f "$bin" 2>/dev/null || echo "$bin")

case "$real" in
    *Cellar/codex/*|*homebrew*/codex*)
        echo "  Updating via Homebrew..."
        brew upgrade codex
        ;;
    *)
        if ! command -v npm > /dev/null 2>&1; then
            echo "  npm not found; load nvm first (or install node)." >&2
            exit 1
        fi
        echo "  Updating via npm ($(dirname "$(command -v npm)"))..."
        npm install -g @openai/codex@latest
        ;;
esac

after=$(codex --version 2>/dev/null || echo "unknown")
echo "  codex: $after"
