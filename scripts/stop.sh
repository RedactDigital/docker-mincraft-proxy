#!/bin/bash

tmux send-keys -t $TMUX_SESSION "stop" ENTER
echo "Stopping Velocity server..."

# While the server is stopping, we want to keep checking if it's still running
# If it's still running, we want to keep waiting
# If it's not running, we want to break out of the loop
while true; do
    # Get the last line of the log file
    LAST_LINE=$(tail -1 $WORKDIR/logs/latest.log)

    # If the last line of the log file contains "Closing endpoint", we know the server has stopped
    if echo "$LAST_LINE" | grep -q "Closing endpoint"; then
        echo "Server has stopped!"
        break
    fi
    sleep 1
done

# Kill the tmux session
tmux kill-session -t $TMUX_SESSION
echo "Velocity server stopped!"
