#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

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

# Unison
#alias usync='unison raspi'

# For renaming groups of files. Examples: 
# zmv  'juliet-(*)' 'prospera-$1'
# zmv '(*).sh' '$1'
# Passing -n to zmv will show you what zmv would do, without doing anything. 
autoload zmv

# show Cabal sandbox status
function cabal_sandbox_info() {
    cabal_files=(*.cabal(N))
    if [ $#cabal_files -gt 0 ]; then
        if [ -f cabal.sandbox.config ]; then
            echo "%{$fg[green]%}sandboxed%{$reset_color%}"
        else
            echo "%{$fg[red]%}not sandboxed%{$reset_color%}"
        fi
    fi
}
 
RPROMPT="\$(cabal_sandbox_info) $RPROMPT"

################################################
###   Manual zshrc file configuration       ###
################################################

setopt No_Beep
