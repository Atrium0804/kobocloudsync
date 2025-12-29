#!/bin/sh
#
# KoboCloudSync - Logging Functions
#
# Provides dual-output logging (screen + file) with verbosity filtering
# and progress display via FBInk for e-ink feedback.
#
# Verbosity levels: 1=error, 2=warning, 3=info, 4=debug (default=4)
if [ -z "$verbosity" ]; then
    verbosity=4
fi

# Logging function - prints to screen and log file
# Usage: log "message" [level]
# Levels: 1=error, 2=warning, 3=info (default), 4=debug
log() {
    local message="$1"
    local level=${2:-3}  # Default to info level

    # Print to stdout if verbosity level is high enough
    if [ "$verbosity" -ge "$level" ]; then
        echo "$message"
    fi

    # Print to device screen using fbink if level is error and on kobo
    if [ "$level" -le 1 ] && [ "$environment" = "kobo" ]; then
        if which fbink >/dev/null 2>&1; then
            fbink -r -q -y -5 --font THIN "$message"
        fi
    fi

    # Always write to log file
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$scriptLogfile"
}

# Progress function - prints progress bar to device screen if fbink is available
# Usage: progress stepCount stepTotal message
progress() {
    local stepCount="$1"
    local stepTotal="$2"
    local message="$3"

    # Generate progress bar with blocks
    local filled=""
    local empty=""
    local i=1

    # Create the required ammount of filled blocks
    while [ $i -le $stepCount ]; do
        filled="${filled}▓"
        i=$((i + 1))
    done

    # Create the required ammount of empty blocks
    i=$((stepCount + 1))
    while [ $i -le $stepTotal ]; do
        empty="${empty}░"
        i=$((i + 1))
    done

    local text="Sync: ${filled}${empty} ${message}"

    # Only attempt fbink on kobo device
    if [ "$environment" = "kobo" ]; then
        # Check if fbink is available in PATH
        if which fbink >/dev/null 2>&1; then
            fbink -r -q -y -5 --font THIN "$text"
        fi
    fi
}
