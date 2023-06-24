#!/bin/bash

# Create a tmux session called "velocity"
echo "---"
echo "Starting Velocity server..."
tmux new-session -d -s "velocity"
tmux send-keys -t "velocity" "./start.sh" ENTER

# If there are no arguments, we want to keep the container running,
# so the tmux session doesn't exit
# Otherwise, we want to execute the command passed through docker
if [ $# = 0 ]; then
    tail -f /dev/null
else
    # execute the command passed through docker
    exec "$@"
fi
