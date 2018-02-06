#!/bin/sh 

# setup session and first window
tmux new-session -d -s "system" -n "system" 
tmux send-keys "clear" 'C-m'

# second window (2)
tmux new-window -n monitor 
tmux send-keys "clear" 'C-m'
tmux split-window -h 
tmux send-keys "clear" 'C-m'
tmux split-window -v 
tmux send-keys "clear" 'C-m'

tmux attach-session -d 
