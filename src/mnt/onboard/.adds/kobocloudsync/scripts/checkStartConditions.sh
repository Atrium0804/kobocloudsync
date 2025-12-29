#!/bin/sh
#
# KoboCloudSync - Start Condition Checks
#
# Validates environment readiness before sync:
#   - checkDependencies: Verifies required binaries exist and are executable
#   - checkRcloneConfig: Ensures rclone configuration file exists
#   - checkNetwork: Tests network connectivity via ping

# Function: Check if required binaries are installed and executable
checkDependencies() {
    log "Checking dependencies..." 3
    for cmd in "$rclone" "$kepubify" "$covergen" "$seriesmeta"; do
        if [ ! -x "$cmd" ]; then
            log "ERROR: required binary $cmd not found or not executable" 1
            return 1
        fi
    done
    log "All dependencies found" 3
    return 0
}

# Function: Check if rclone config file exists
checkRcloneConfig() {
    log "Checking rclone config..." 3
    if [ ! -f "$rclone_config_file" ]; then
        log "ERROR: rclone config file $rclone_config_file not found" 1
        return 1
    fi
    log "Rclone config found" 3
    return 0
}

# Function: Check for working network connection
checkNetwork() {
    log "Checking network connection..." 3
    # set device specific wait-parameter
    case $device in
    "kobo") waitparm='-w'
            timeout=30
            pingcmd="ping -c 1 $waitparm 3"
        ;;
         *) if uname -a | grep -q 'W64_NT'; then
                # Windows ping syntax
                timeout=2
                pingcmd="ping -n 1 -w 3000"
            else
                # Mac/Linux ping syntax
                waitparm='-i'
                timeout=2
                pingcmd="ping -c 1 $waitparm 3"
            fi
         ;;
    esac

    r=1;i=0
    while [ $r != 0 ]; do
        if [ $i -gt $timeout ]; then
            log "ERROR: No connection detected" 1
            return 1
        fi
        $pingcmd aws.amazon.com >/dev/null 2>&1
        r=$?
        if [ $r != 0 ]; then sleep 1; fi
        i=$(($i + 1))
    done
    log "Network connection found" 3
    return 0
}
