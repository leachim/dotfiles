#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# source profile file
[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...


# NON-INTERACTIVE SHELLS {{{
_source () { [[ -f $1 ]] && source $1 }
_source ~/.aliases



# Test for an interactive shell.
[[ -t 1 ]] || return
# }}}

# SETTINGS {{{
WORDCHARS="${WORDCHARS:s#/#}"
KEYTIMEOUT=5

# flow control
stty -ixon -ixoff

# history
HISTSIZE=4000
HISTFILE=$HOME/.zsh_history
SAVEHIST=4000
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt incappendhistory

# cd
setopt autocd
setopt autopushd
setopt pushdsilent

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
# }}}

# COMPLETION {{{
autoload -U compinit && compinit

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' menu select

# case-insensitive -> partial-word -> substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

## do not share history between terminals
unsetopt share_history


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
