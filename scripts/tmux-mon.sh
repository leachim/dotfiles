#!/bin/sh 

# setup session and first window
tmux new-session -d -s "system" -n "system" 
tmux send-keys "clear" 'C-m'

# second window (2)
tmux new-window -n monitor 
tmux send-keys "clear" 'C-m' "htop" "C-m"
# tmux split-window -h
# tmux send-keys "clear" 'C-m'
tmux split-window -v 
tmux send-keys "clear" 'C-m'

# third window (3)
tmux new-window -n jupyter 
tmux send-keys "clear" 'C-m'
tmux send-keys "cd ~/current/lab" "C-m" "jupyter lab" 'C-m'

tmux attach-session -d 
