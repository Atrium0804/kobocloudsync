#!/bin/sh

# Check start conditions for KoboCloudSync
# - check if dependencies are installed
# - check if rclone config file exists and valid
# - check for working network-connection

# check if dependencies are installed
log ""
log "----------------------------"
log "Checking start conditions..."
for cmd in "$rclone" "$kepubify" "$covergen" "$seriesmeta"; do
    if [ ! -x "$cmd" ]; then
        log "ERROR: required binary $cmd not found or not executable"
        exit 1
    fi
done

# check if rclone config file exists and valid
if [ ! -f "$rclone_config_file" ]; then
    log "ERROR: rclone config file $rclone_config_file not found"
    exit 1
fi

# check for working network-connection
. $scripts_folder/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ];
then
    log "ERROR: No network connection, aborting"
    exit 1
fi

log "All start conditions met, proceeding"
