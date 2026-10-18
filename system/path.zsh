# Base PATH order.
#
# This is deliberately the ONLY file that orders the system prefixes. It used to
# be split between system/_path.zsh and homebrew/path.zsh, and because the
# leading underscore kept `_path.zsh` out of zshrc's `*/path.zsh` pass, it loaded
# *after* the homebrew prepend and pushed /usr/local/bin back in front of it --
# so a stale Intel-era binary in /usr/local/bin shadowed the brew one.
#
# `typeset -U path` (set in zshrc) keeps the leftmost occurrence, so prepending
# here promotes an entry even if it already appears further down.

path=(/usr/local/bin /usr/local/sbin $path)

# Homebrew must outrank /usr/local/bin, which is both a hand-install dumping
# ground and the Intel brew prefix.
[[ -d /opt/homebrew/bin ]] && path=(/opt/homebrew/bin /opt/homebrew/sbin $path)

# Completions for brew and brew-installed tools. macOS /bin/zsh only knows the
# Intel prefix (/usr/local/share/zsh/site-functions).
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

path=("$DOTFILES/bin" $path)

export MANPATH="/usr/local/man:$MANPATH"
