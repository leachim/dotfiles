#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# NON-INTERACTIVE SHELLS {{{
_source () { [[ -f $1 ]] && source $1 }
_source ~/.aliases

# source profile file
[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Test for an interactive shell.
[[ -t 1 ]] || return
# }}}

# SETTINGS {{{
WORDCHARS="${WORDCHARS:s#/#}"
KEYTIMEOUT=1

# flow control
stty -ixon -ixoff

# history
HISTSIZE=8000
HISTFILE=$HOME/.zsh_history
SAVEHIST=8000
setopt hist_ignore_all_dups
setopt hist_ignore_space
# save every command before it is executed
setopt inc_append_history
setopt incappendhistory

# cd
setopt autocd
setopt autopushd
setopt pushdsilent

# ignore ctrl-d command to close terminal
setopt ignoreeof

# prompt
setopt extendedglob
setopt nolistambiguous
setopt prompt_subst
setopt nobeep

# job
setopt nohup
setopt nocheckjobs
setopt nobgnice
# }}}

# IMPORTS {{{
_source ~/.zsh/aliases
_source ~/.zsh/bookmarks
_source ~/.autocompletion/docker-machine.zsh
# }}}

# COMPLETION {{{
autoload -U compinit && compinit

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' menu select

# case-insensitive -> partial-word -> substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

## share history between terminals
#unsetopt share_history
setopt share_history

# access global and local history for each shell
# https://superuser.com/questions/446594/separate-up-arrow-lookback-for-local-and-global-zsh-history
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey "^[0A" up-line-or-local-history
bindkey "^[0B" down-line-or-local-history
bindkey "^[[1;5A" up-line-or-beginning-search # [CTRL] + Cursor up
bindkey "^[[1;5B" down-line-or-beginning-search # [CTRL] + Cursor down

### keep below

# For renaming groups of files. Examples: 
# zmv  'juliet-(*)' 'prospera-$1'
# zmv '(*).sh' '$1'
# Passing -n to zmv will show you what zmv would do, without doing anything. 
autoload zmv

################################################
###   Manual zshrc file configuration       ###
################################################

setopt NO_BEEP

## to insert all the compliteon matches into the command line
#https://stackoverflow.com/questions/28078756/how-to-add-all-tab-completitions-to-my-current-command

zle -C all-matches complete-word _my_generic
zstyle ':completion:all-matches::::' completer _all_matches
zstyle ':completion:all-matches:*' old-matches only
_my_generic () {
      local ZSH_TRACE_GENERIC_WIDGET=  # works with "setopt nounset"
        _generic "$@"
}
bindkey '^X^a' all-matches

# break of in the middle of writing command
# https://sgeb.io/posts/2016/11/til-bash-zsh-half-typed-commands/
bindkey '^q' push-line-or-edit


################################################
zbell_duration=300
# This script prints a bell character when a command finishes
# if it has been running for longer than $zbell_duration seconds.
# If there are programs that you know run long that you don't
# want to bell after, then add them to $zbell_ignore.
#
# This script uses only zsh builtins so its fast, there's no needless
# forking, and its only dependency is zsh and its standard modules
#
# Written by Jean-Philippe Ouellet <jpo@vt.edu>
# Made available under the ISC license.

# only do this if we're in an interactive shell
[[ -o interactive ]] || return

# get $EPOCHSECONDS. builtins are faster than date(1)
zmodload zsh/datetime || return

# make sure we can register hooks
autoload -Uz add-zsh-hook || return

# initialize zbell_duration if not set
(( ${+zbell_duration} )) || zbell_duration=15

# initialize zbell_ignore if not set
(( ${+zbell_ignore} )) || zbell_ignore=($EDITOR $PAGER)

# initialize it because otherwise we compare a date and an empty string
# the first time we see the prompt. it's fine to have lastcmd empty on the
# initial run because it evaluates to an empty string, and splitting an
# empty string just results in an empty array.
zbell_timestamp=$EPOCHSECONDS

# right before we begin to execute something, store the time it started at
zbell_begin() {
	zbell_timestamp=$EPOCHSECONDS
	zbell_lastcmd=$1
}

# when it finishes, if it's been running longer than $zbell_duration,
# and we dont have an ignored command in the line, then print a bell.
zbell_end() {
	ran_long=$(( $EPOCHSECONDS - $zbell_timestamp >= $zbell_duration ))

	has_ignored_cmd=0
	for cmd in ${(s:;:)zbell_lastcmd//|/;}; do
		words=(${(z)cmd})
		util=${words[1]}
		if (( ${zbell_ignore[(i)$util]} <= ${#zbell_ignore} )); then
			has_ignored_cmd=1
			break
		fi
	done

	if (( ! $has_ignored_cmd )) && (( ran_long )); then
		print -n "\a"
	fi
}

# register the functions as hooks
add-zsh-hook preexec zbell_begin
add-zsh-hook precmd zbell_end
################################################

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

PATH="/home/michael/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/michael/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/michael/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/michael/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/michael/perl5"; export PERL_MM_OPT;


export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
