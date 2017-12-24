# ~/.bashrc: executed by bash(1) for non-login shells.

## Load paths and variables
source ~/.profile

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# fix issue with tmux colors -> remove as leads to problems with htop
#export TERM="xterm-256color"
force_color_prompt=yes

## add specific file colors
if [ -f ~/.dir_colors ] ; then
    eval "`dircolors -b ~/.dir_colors`"
fi

# BASH OPTIONS {{{
shopt -s cdspell                 # Correct cd typos
shopt -s checkwinsize            # Update windows size on command
#shopt -s extglob                 # Extended pattern
shopt -s no_empty_cmd_completion  # No empty completion

# append to the history file, don't overwrite it
shopt -s histappend
# Combine multiline commands into one in history
shopt -s cmdhist
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
export HISTIGNORE="&:ls:[bf]g:exit"

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# Colorful bash 
alias ls="ls --color=auto"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Prompt
# --------------------------------------------------------------------
### git-prompt
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_SHOWCOLORHINTS=1
__git_ps1() { :;}
if [ -f ~/.dotfiles/files/git-prompt.sh ]; then
    source ~/.dotfiles/files/git-prompt.sh
fi
# PROMPT_COMMAND='history -a; printf "\[\e[38;5;59m\]%$(($COLUMNS - 4))s\r" "$(__git_ps1) ($(date +%m/%d\ %H:%M:%S))"'
PROMPT_COMMAND='history -a; printf "\[\e[38;5;59m\]%$(($COLUMNS - 4))s\r" "$(__git_ps1)"'
PS1="\[\e[34m\]\u\[\e[1;32m\]@\[\e[0;33m\]\h\[\e[35m\]:"
PS1="$PS1\[\e[m\]\w\[\e[1;31m\]> \[\e[0m\]"
#PS1="$PS1\[\e[0;38m\]\w\[\e[1;35m\]> \[\e[0m\]"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

