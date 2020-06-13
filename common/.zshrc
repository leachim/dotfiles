
# Test for an interactive shell.
[[ -t 1 ]] || return

export XDG_CACHE_HOME=${XDG_CACHE_HOME:=~/.cache}

## SET OPTIONS
typeset -g HISTSIZE=500000 SAVEHIST=500000 HISTFILE=~/.zhistory


#
# Setopts
#

setopt interactive_comments hist_ignore_dups  octal_zeroes   no_prompt_cr
setopt no_hist_no_functions no_always_to_end  append_history list_packed
setopt inc_append_history   complete_in_word  auto_pushd     complete_aliases
setopt pushd_ignore_dups    no_glob_complete  no_glob_dots   c_bases
setopt numeric_glob_sort    no_share_history  promptsubst    auto_cd
setopt rc_quotes            extendedglob      notify

setopt IGNORE_EOF
# setopt no_auto_menu
#setopt NO_SHORT_LOOPS
#setopt PRINT_EXIT_VALUE
#setopt RM_STAR_WAIT

# improvements to history handling
setopt extendedhistory histexpiredupsfirst histverify
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS INC_APPEND_HISTORY
setopt histignorespace
# cd
setopt autocd autonamedirs autopushd pushdsilent pushdignoredups cdablevars
# ignore ctrl-d command to close terminal
setopt ignoreeof nolistambiguous prompt_subst nobeep
# job
setopt nohup nocheckjobs nobgnice
# share history between terminals
#unsetopt share_history
setopt share_history

## autocompletion and history search
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' menu select

# case-insensitive -> partial-word -> substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

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

# some more
autoload -Uz edit-command-line
zle -N edit-command-line
#bindkey -M vicmd v edit-command-line

autoload -Uz select-word-style
select-word-style shell

# Notifications
#PS1="READY > "
zstyle ":plugin:zconvey" greeting "none"
zstyle ':notify:*' command-complete-timeout 3
zstyle ':notify:*' notifier plg-zsh-notify



##
## zinit
##

## http://zdharma.org/zinit
source ~/.zinit/bin/zinit.zsh

setopt promptsubst

# Fast-syntax-highlighting & autosuggestions
zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
    zdharma/fast-syntax-highlighting \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
 blockf \
    zsh-users/zsh-completions

zinit wait lucid for \
        OMZ::lib/git.zsh \
        OMZ::lib/prompt_info_functions.zsh \
        OMZ::lib/clipboard.zsh \
        OMZ::plugins/git-prompt/git-prompt.plugin.zsh \
        OMZ::plugins/common-aliases/common-aliases.plugin.zsh \
        OMZ::plugins/vi-mode/vi-mode.plugin.zsh \
        OMZ::plugins/history-substring-search/history-substring-search.zsh \
  atload"unalias grv" \
  atload"unalias gc" \
  atload"unalias gm" \
        OMZ::plugins/git/git.plugin.zsh

# too verbose
# OMZ::plugins/per-directory-history/per-directory-history.zsh \
# Press ^G (the Control and G keys simultaneously) to toggle between local and global histories. If you would prefer a different shortcut to toggle set the PER_DIRECTORY_HISTORY_TOGGLE environment variable.

PS1=">" # provide a simple prompt till the theme loads

### THEME ###
zinit ice depth=1; zinit light romkatv/powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.dotfiles/common/.p10k.zsh ]] || source ~/.dotfiles/common/.p10k.zsh

# zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
# zinit light sindresorhus/pure

# zinit wait'!' lucid for \
    # halfo/lambda-mod-zsh-theme
     # atload'!_agkozak_precmd' nocd atinit'AGKOZAK_FORCE_ASYNC_METHOD=subst-async' for \
        # agkozak/agkozak-zsh-theme
    # OMZT::sorin
# other themes: avit, sorin,

## Completion block
zi_completion() {
    zinit ice lucid wait'5' as'completion' blockf "$@"
}
zi_completion has'cargo'
zinit snippet https://github.com/rust-lang/cargo/blob/master/src/etc/_cargo

zi_completion has'rustc'
zinit snippet OMZP::rust

zi_completion has'docker'
zinit snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zi_completion has'alacritty'
zinit snippet https://github.com/alacritty/alacritty/blob/master/extra/completions/_alacritty

zi_completion has'wl-copy'
zinit snippet https://github.com/bugaevc/wl-clipboard/blob/master/completions/zsh/_wl-copy

zi_completion has'wl-paste'


# Compiling programs

# LS_COLORS Explanation
zinit ice atclone"dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*" list-colors “${(s.:.)LS_COLORS}”'
zinit light trapd00r/LS_COLORS

# Direnv Explanation
zinit as"program" make'!' atclone'./direnv hook zsh > zhook.zsh' \
        atpull'%atclone' pick"direnv" src"zhook.zsh" for \
                direnv/direnv

# vim
zinit ice as"program" atclone"rm -f src/auto/config.cache; ./configure" \
    atpull"%atclone" make pick"src/vim"
zinit light vim/vim

# junegunn/fzf-bin
zinit pack for fzf
zinit ice from"gh-r" as"program"
zinit light junegunn/fzf-bin

# sharkdp/fd
zinit ice as"command" from"gh-r" mv"fd* -> fd" pick"fd/fd"
zinit light sharkdp/fd

# sharkdp/bat
zinit ice as"command" from"gh-r" mv"bat* -> bat" pick"bat/bat"
zinit light sharkdp/bat

zinit ice as"program" pick"yank" make
zinit light mptre/yank

# tmux-panes
zinit light greymd/tmux-xpanes

# NEOVIM
zinit ice from"gh-r" as"program" bpick"*appimage*" mv"nvim* -> nvim" pick"nvim"
zinit light neovim/neovim

## load more stuff
zinit wait lucid for \
    zdharma/history-search-multi-word \
  atinit"zicompinit; zicdreplay"  \
        OMZ::plugins/colorize/colorize.plugin.zsh \
        OMZ::plugins/fzf/fzf.plugin.zsh \
  as"completion" \
        OMZ::plugins/urltools/urltools.plugin.zsh \
        OMZ::plugins/web-search/web-search.plugin.zsh \
        OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh \
        OMZ::plugins/git-flow/git-flow.plugin.zsh

# TAB COMPLETIONS
#

# case-insensitive -> partial-word -> substring completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '-- %d --'
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:complete:*:options' sort false
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:cd:*' extra-opts --preview=$extract'exa -1 --color=always ${~ctxt[hpre]}$in'
bindkey '^[[Z' reverse-menu-complete

# ctrl-Y from bash - replicate in zsh
bindkey "^Y" yank

# break of in the middle of writing command
# https://sgeb.io/posts/2016/11/til-bash-zsh-half-typed-commands/
bindkey '^q' push-line-or-edit

# Notifications
# not needed with ring
# zinit wait lucid for marzocchi/zsh-notify

zinit wait lucid light-mode for \
    as"completion" esc/conda-zsh-completion

# Conda issue -> avoid long startup time by lazy loading conda environment
# https://github.com/zdharma/zinit/issues/68
zplugin light romkatv/zsh-defer
zsh-defer +a -p -t 3 -c "source ~/.conda_startup"

# 
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

export NVM_DIR="$HOME/.nvm"
[ -f "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[ -f ~/.aliases ] && source ~/.aliases

[ -f ~/.dotfiles/common/.gitalias ] && source ~/.dotfiles/common/.gitalias

[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

