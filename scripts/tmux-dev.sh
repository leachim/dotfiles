#!/bin/sh 

# setup session and first window
tmux new-session -d -s "$1" -n "$1" 
tmux send-keys "source activate ${1}" 'C-m' "clear" 'C-m'

# second window (2)
tmux new-window -n test 
tmux send-keys "source activate ${1}" 'C-m' "clear" 'C-m'
tmux split-window -h 
tmux send-keys "source activate ${1}" 'C-m' "clear" 'C-m'
tmux split-window -v 
tmux send-keys "source activate ${1}" 'C-m' "clear" 'C-m'
tmux split-window -v 
tmux send-keys "source activate ${1}" 'C-m' "clear" 'C-m'

tmux attach-session -d 
