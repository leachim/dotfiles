# matches case insensitive for lowercase. oh-my-zsh sets a fuller matcher-list
# (case, hyphen/underscore and partial-word matching), so only without it.
[[ -f $ZSH/oh-my-zsh.sh ]] || zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending
