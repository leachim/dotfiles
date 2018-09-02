# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# added by Anaconda3 installer
export PATH="$HOME/.anaconda3/bin:/snap/bin:/opt/bin:$HOME/.local/bin:/opt/bin:$HOME/.dotfiles/bin:$PATH"

# Java dependencies
export JAVA_HOME=/usr/lib/jvm/default-java
export PATH=$PATH:/usr/lib/jvm/default-java/bin

# fix CURL certificates path
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# export cuda
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib"
export CUDA_HOME=/usr/

# soft notification sound
export BEEP=/home/michael/.dotfiles/files/soft_beep.way

# create fixed tmux session directory, to restore tmux sessions remotely
mkdir -p $HOME/.tmux_socket;
export TMUX_TMPDIR=~/.tmux_socket

# fzf environment variables
if [ -e ~/.fzf ]; then
	export FZF_DEFAULT_COMMAND='ag --nocolor -g ""'
	export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND"
	export FZF_DEFAULT_OPTS='
	--color fg:242,bg:236,hl:65,fg+:15,bg+:239,hl+:108
	--color info:108,prompt:109,spinner:108,pointer:168,marker:168
	'
fi

# added by travis gem
[ -f /home/michael/.travis/travis.sh ] && source /home/michael/.travis/travis.sh

TZ='Europe/London'; export TZ

# if running from tty1 start sway  -> desktop session
if [ $(tty) = "/dev/tty1" ]; then
    export XKB_DEFAULT_LAYOUT=us,de
    export XKB_DEFAULT_VARIANT=nodeadkeys
    export XKB_DEFAULT_OPTIONS=grp:alt_shift_toggle

    # export WLC_REPEAT_DELAY=100
    # export WLC_REPEAT_RATE=1
    # export SWAY_CURSOR_THEME=""
    # export SWAY_CURSOR_SIZE=5
    sway 
    exit 0
fi

