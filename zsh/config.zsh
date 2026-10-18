export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=true

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# You may need to manually set your language environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# History
setopt EXTENDED_HISTORY        # add timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST  # expire duplicates first when trimming
setopt HIST_IGNORE_ALL_DUPS    # remove older duplicate entries
setopt HIST_IGNORE_SPACE       # ignore commands starting with space
setopt HIST_REDUCE_BLANKS      # remove superfluous blanks
setopt HIST_VERIFY             # show expansion before executing
setopt INC_APPEND_HISTORY      # write immediately, not on shell exit
setopt NO_SHARE_HISTORY        # don't share between concurrent sessions

# Directory navigation
setopt AUTO_CD                 # cd by typing directory name
setopt AUTO_PUSHD              # push directories on cd
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt CDABLE_VARS
setopt AUTO_NAME_DIRS

# Completion
setopt COMPLETE_IN_WORD
setopt COMPLETE_ALIASES
setopt NO_LIST_AMBIGUOUS
setopt LIST_PACKED
setopt NO_GLOB_COMPLETE
setopt NO_GLOB_DOTS

# Shell behavior
setopt PROMPT_SUBST
setopt CORRECT
setopt IGNORE_EOF
setopt INTERACTIVE_COMMENTS
setopt EXTENDED_GLOB
setopt NUMERIC_GLOB_SORT
setopt RC_QUOTES
setopt NOTIFY
setopt NO_BEEP
setopt NO_PROMPT_CR
setopt OCTAL_ZEROES
setopt C_BASES
setopt NO_ALWAYS_TO_END
setopt NO_HIST_NO_FUNCTIONS

# Jobs
setopt NO_HUP
setopt NO_CHECK_JOBS
setopt NO_BG_NICE
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS
