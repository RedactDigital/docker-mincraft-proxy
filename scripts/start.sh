#!/bin/sh

COMMAND="java -Xms1G -Xmx1G -XX:+UseG1GC -XX:G1HeapRegionSize=4M -XX:+UnlockExperimentalVMOptions -XX:+ParallelRefProcEnabled -XX:+AlwaysPreTouch -XX:MaxInlineLevel=15 -jar $WORKDIR/velocity*.jar"

# See if a tmux session already exists, if it doesn't, create one
if ! tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
    echo "No tmux session found, creating one..."
    tmux new-session -d -s "$TMUX_SESSION"
fi

# Start the server in the tmux session
echo "Starting Velocity server..."
tmux send-keys -t "$TMUX_SESSION" "$COMMAND" ENTER

# While the server is starting, we want to keep checking if it's still starting
# If it's still starting, we want to keep waiting
# If it's not starting, we want to break out of the loop
while true; do
    # Get the last line of the log file
    LAST_LINE=$(tail -1 $WORKDIR/logs/latest.log)

    # If the last line of the log file contains "Done", we know the server has started
    if echo "$LAST_LINE" | grep -q "Done"; then
        echo "Server has started!"
        break
    fi
    sleep 1
done

CONFIG_FILES="velocity.toml forwarding.secret"

# If there is a /config directory mounted, we will loop through all the CONFIG_FILES
# and check if they exist in /config. If they don't, we will copy the ones that
# that are missing from the WORKDIR to /config
if [ -d /config ]; then
    for file in $CONFIG_FILES; do
        if [ ! -f /config/$file ]; then
            echo "Copying $file to /config"
            cp $WORKDIR/$file /config/$file
        fi
    done

    # Now we loop through all the files in it and create a symlink to them.
    # Since we already checked if the file exists in /config, we don't need to
    # check if the file exists in /config before creating the symlink
    for file in $CONFIG_FILES; do
        filename=$(basename $file)
        if [ -f $WORKDIR/$filename ]; then
            echo "Removing $filename from $WORKDIR so we can create a symlink"
            rm $WORKDIR/$filename
        fi
        echo "Creating symlink for $filename"
        ln -s /config/$file $WORKDIR/$filename
    done
fi
