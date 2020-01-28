# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login exists.

export PATH="/snap/bin:/opt/bin:$HOME/.local/bin:/opt/bin:$HOME/.dotfiles/bin:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="/home/$USER/.cargo/bin:$PATH"
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

# create fixed tmux session directory, to restore tmux sessions remotely
if [ -e ~/.tmux_conf ]; then
    # mkdir -p $HOME/.tmux_socket;
    export TMUX_TMPDIR=~/.tmux_socket
fi

# load arbitrary API environment variables
if [ -e ~/.env ]; then
    source ~/.env
fi

# fzf environment variables
if [ -e ~/.fzf ]; then
	export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_DEFAULT_OPTS=' --color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108 --color info:108,prompt:109,spinner:108,pointer:168,marker:168'
fi

# fasd
if [ -e ~/.fasd ]; then
    eval "$(fasd --init auto)"
fi

# broot
if [ -f ~/.cargo/bin/broot ]; then
    source ~/.config/broot/launcher/bash/br
fi

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

# per host configuration
if [ -f ~/.profile_hosts ]; then
    source ~/.profile_hosts
fi

# make sure conda base environment is activated in default shell
if type "conda" > /dev/null; then
    conda activate 
fi
