# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# BASH OPTIONS {{{
shopt -s cdspell                 # Correct cd typos
shopt -s checkwinsize            # Update windows size on command
#shopt -s extglob                 # Extended pattern
shopt -s no_empty_cmd_completion  # No empty completion

# Combine multiline commands into one in history
shopt -s cmdhist
# checks the window size after each command 
shopt -s checkwinsize

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=50000
HISTFILESIZE=100000
# don't put duplicate lines or lines starting with space in the history.
# https://unix.stackexchange.com/questions/18212/bash-history-ignoredups-and-erasedups-setting-conflict-with-common-history
HISTCONTROL=ignoreboth
shopt -s histappend
export HISTIGNORE="&:ls:[bf]g:exit"
export IGNOREEOF=5   # Shell only exists after the 10th consecutive Ctrl-d<Paste>
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac
#

force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
    else
  color_prompt=
    fi
fi

## add specific file colors
if [ -f ~/.dir_colors ] ; then
    eval "`dircolors -b ~/.dir_colors`"
fi

# Get repo info
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;91m\]\u\[\033[01;37m\] at \[\033[01;33m\]\h\[\033[01;37m\]:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " \[\033[01;32m\][%s]")\[\033[00m\]\$ '
    PS2="> "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in 
    xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


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

# some usefull functions
extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       rar x $1       ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}

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


# Tab autocompletion functionality for bash emulating zsh behavior
bind 'TAB:menu-complete'
bind '"\e[Z": menu-complete-backward'
bind "set show-all-if-ambiguous on"
bind "set show-all-if-unmodified off"
bind "set menu-complete-display-prefix on"

# Bash use vi style keybindings
set -o vi

# some more ls aliases
alias lst="ls -lt"
alias ll='ls -alF'
alias sl="ls"
alias la='ls -A'
alias l='ls -CF'
alias c="clear"
alias cdp="cd -P"
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias takeover="tmux detach -a"
alias vi="vim"
alias le="less"

if [ -x "$(command -v fasd)" ]; then
    # quicker startup with fasd
    fasd_cache="$HOME/.fasd-init-bash"
    if [ "$(command -v fasd)" -nt "$fasd_cache" -o ! -s "$fasd_cache" ]; then
      fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install >| "$fasd_cache"
    fi
    if [ -e $fasd_cache ]; then
        source "$fasd_cache"
    fi
    unset fasd_cache
fi

#######################################################
# BEGIN PROMPT DEFINITION

# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
	userStyle="\e[1;31m"; # red
else
    userStyle="\e[38;5;33m"; # blue
    #userStyle="\e[38;5;166m"; # orange
fi;
hostStyle="\e[1;33m"; # yellow
gitStyle="\e[38;5;64m"; # green

if [ -x "$(command -v fasd)" ] && type _fasd_prompt_func | grep -i function > /dev/null; then
    # per terminal history
    #PROMPT_COMMAND='history -w; history -c; history -r; _fasd_prompt_func;'
    # shared history
    PROMPT_COMMAND='history -n; history -w; history -c; history -r; _fasd_prompt_func;'
else
    PROMPT_COMMAND='history -n; history -w; history -c; history -r;'
fi
PROMPT_COMMAND+='__git_ps1 "\[${userStyle}\]\u\[\e[1;32m\]@\[${hostStyle}\]\h\[\e[35;m\]:'

# choice between short and long version of path:
PROMPT_COMMAND+='\[\e[m\]$(sed -e "s:$HOME:~:" -e "s:\(\.\?[^/]\)[^/]*/:\1/:g" <<<$PWD)'
#PROMPT_COMMAND+='\[\e[m\]\w\[\e[1;31m\]'

# git line
PROMPT_COMMAND+='\[\e[0m\]" "\[${gitStyle}\]\[\e[m\]'
PROMPT_COMMAND+='\[\e[1;31m\]> ' 

PROMPT_COMMAND+='\[\e[0m\]"'

# END PROMPT DEFINITION
#########################################

if [ -n "$SINGULARITY_CONTAINER" ]; then
    PS1=$SINGULARITY_CONTAINER":"$PS1
fi

# Load paths and variables
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

if [ -f ~/.autocompletion/docker-machine.bash ]; then 
    source ~/.autocompletion/docker-machine.bash
fi

