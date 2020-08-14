# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.

export PATH="/snap/bin:/opt/bin:$HOME/.local/bin:/opt/bin:$HOME/.dotfiles/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/home/$USER/.cargo/bin:$PATH"
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
alias tmux='TERM=xterm-256color tmux'

# create fixed tmux session directory, to restore tmux sessions remotely
if [ -e ~/.tmux_conf ]; then
    # mkdir -p $HOME/.tmux_socket;
    export TMUX_TMPDIR=~/.tmux_socket
fi

# load arbitrary API environment variables
if [ -f ~/.env ]; then
    source ~/.env
fi

# fzf environment variables
## https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf
# Uncomment the following line to disable fuzzy completion
# export DISABLE_FZF_AUTO_COMPLETION="true"
# Uncomment the following line to disable key bindings (CTRL-T, CTRL-R, ALT-C)
# export DISABLE_FZF_KEY_BINDINGS="true"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [ -e ~/.fzf ]; then
	export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='
                    --color=dark
                    --color fg:124,bg:16,hl:202,fg+:214,bg+:52,hl+:231
                    --color info:52,prompt:196,spinner:208,pointer:196,marker:208'
fi

# fasd
if [ command -v COMMAND &> /dev/null ]; then
# if [ -e ~/.fasd ]; then
    eval "$(fasd --init auto)"
fi

# broot
if [ -f "$HOME/.config/broot/launcher/bash/br" ]; then
    source "$HOME/.config/broot/launcher/bash/br"
fi

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

[ -f ~/.gitalias ] && source ~/.gitalias

# per host configuration
if [ -f ~/.profile_hosts ]; then
    source ~/.profile_hosts
fi
