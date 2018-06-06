#!/bin/sh 

# setup session and first window
tmux new-session -d -s "$1" -n "$1" 
tmux send-keys "clear" 'C-m'
tmux split-window -h

# second window (2)
if [ "$1" = "Desktop" ]; then
  tmux new-window -n control
elif [ "$1" = "Data" ]; then
  tmux new-window -n transfer
elif [ "$1" = "Clust" ]; then
  tmux new-window -n monitor
else
  tmux new-window -n test
fi
tmux split-window -h
tmux send-keys "clear" 'C-m' "htop" "C-m"
# tmux send-keys "clear" 'C-m'
tmux split-window -v 
tmux send-keys "clear" 'C-m'

# third window (3)
#tmux new-window -n jupyter 
#tmux send-keys "clear" 'C-m'
#tmux send-keys "cd ~/current/lab" "C-m" "jupyter lab" 'C-m'

tmux attach-session -d 
