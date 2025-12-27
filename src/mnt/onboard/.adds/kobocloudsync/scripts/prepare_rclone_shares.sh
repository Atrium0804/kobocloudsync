#!/bin/sh

# prepare_rclone_shares.sh
#
# Purpose:
#   Reads remote shares from rclone configuration file and prepares local infrastructure
#   for syncing files from each share.
#
# Functionality:
#   1. Load configuration from config.sh to get paths to binaries and folders
#   2. Fetch list of remote shares from rclone config file
#   3. Clean up obsolete local folders for shares removed from rclone config
#   4. For each active share:
#      - Create target folder if it doesn't exist
#      - Create empty local metadata file if it doesn't exist
#      - Download remote metadata (file listing with size, timestamp, path)
#
# Input:
#   - rclone config file (path from config.sh: $rclone_config_file)
#
# Output:
#   - Target folders created in $document_folder/
#   - Local metadata files: ${currentShare}_metadata_local.txt
#   - Remote metadata files: ${currentShare}_metadata_remote.txt
#
# Exit codes:
#   0 - Success
#   1 - Error (no shares found, failed to fetch remote metadata)
#
# Dependencies:
#   - config.sh (must be sourced first)
#   - rclone binary
#
# Usage:
#   . $(dirname $0)/prepare_rclone_shares.sh

log ""
log "----------------------------"
log "Preparing rclone shares..."

SCRIPT_DIR="$(dirname "$0")"

# Load configuration
if [ ! -f "$SCRIPT_DIR/config.sh" ]; then
    log "ERROR: config.sh not found in $SCRIPT_DIR"
    exit 1
fi
. "$SCRIPT_DIR/config.sh"

# Validate configuration
if [ -z "$rclone" ] || [ ! -x "$rclone" ]; then
    log "ERROR: rclone binary not found or not executable: $rclone"
    exit 1
fi

if [ -z "$rclone_config_file" ] || [ ! -f "$rclone_config_file" ]; then
    log "ERROR: rclone config file not found: $rclone_config_file"
    exit 1
fi

if [ -z "$document_folder" ]; then
    log "ERROR: document_folder not set in config"
    exit 1
fi

# Function: Fetch list of remote shares from rclone config
fetch_rclone_shares() {
    local shares
    shares=$("$rclone" listremotes $rcloneOptions | sed 's/://')

    if [ -z "$shares" ]; then
        log "ERROR: No shares found in config file: $rclone_config_file"
        exit 1
    fi

    echo "$shares"
}

# Function: Clean up folders for shares that no longer exist
cleanup_obsolete_folders() {
    local shares="$1"

    log "Checking for obsolete target folders..."

    if [ ! -d "$document_folder" ]; then
        log "  [INFO] Document folder does not exist yet: $document_folder"
        return 0
    fi

    find "$document_folder" -mindepth 1 -maxdepth 1 -type d | while IFS= read -r local_dir; do
        local folder_name
        folder_name=$(basename "$local_dir")

        if echo "$shares" | grep -q "^${folder_name}$"; then
            # Folder exists in shares, keep it
            :
        else
            # Folder does not exist in shares, delete it and associated metadata
            log "  [DELETE] Removing target folder for deleted share: $folder_name"
            rm -rf "$local_dir"
            rm -f "$document_folder/${folder_name}${METADATA_LOCAL_SUFFIX}"
            rm -f "$document_folder/${folder_name}${METADATA_REMOTE_SUFFIX}"
        fi
    done

    log "  [OK] Target folder cleanup complete"
}

# Function: Create target folder if it doesn't exist
ensure_target_folder() {
    local target_folder="$1"

    if [ ! -d "$target_folder" ]; then
        log "  Creating target folder: $target_folder"
        mkdir -p "$target_folder"
        if [ $? -ne 0 ]; then
            log "  [ERROR] Failed to create target folder: $target_folder"
            return 1
        fi
    fi
    return 0
}

# Function: Create empty local metadata file if it doesn't exist
ensure_local_metadata_file() {
    local metadata_file="$1"

    if [ ! -f "$metadata_file" ]; then
        log "  Creating empty local metadata file: $metadata_file"
        touch "$metadata_file"
        if [ $? -ne 0 ]; then
            log "  [ERROR] Failed to create metadata file: $metadata_file"
            return 1
        fi
    fi
    return 0
}

# Function: Download remote metadata for a share
download_remote_metadata() {
    local share="$1"
    local metadata_file="$2"

    log "  Fetching remote metadata for $share..."
    "$rclone" lsl "$share":/ $rcloneOptions > "$metadata_file"

    if [ $? -ne 0 ]; then
        log "  [ERROR] Failed to fetch remote metadata for $share"
        return 1
    fi

    log "  [OK] Remote metadata retrieved for $share"
    return 0
}

# Main function: Prepare all rclone shares
prepare_rclone_shares() {
    log ""
    log "Fetching remote shares from rclone config file..."

    local shares
    shares=$(fetch_rclone_shares)

    log "Found the following shares:"
    log "$shares" | sed 's/^/  - /'
    log ""

    # Clean up obsolete folders for shares that no longer exist
    cleanup_obsolete_folders "$shares"
    log ""

    # Process each share
    local share_count
    share_count=$(echo "$shares" | wc -l)
    local share_num=0

    echo "$shares" | while IFS= read -r current_share; do
        share_num=$((share_num + 1))

        log ""
        log "[$share_num/$share_count] Processing share: $current_share"

        local target_folder="$document_folder/$current_share"
        local file_metadata_local="$document_folder/${current_share}${METADATA_LOCAL_SUFFIX}"
        local file_metadata_remote="$document_folder/${current_share}${METADATA_REMOTE_SUFFIX}"

        # Create target folder
        if ! ensure_target_folder "$target_folder"; then
            log "[ERROR] Failed to prepare share: $current_share"
            exit 1
        fi

        # Create local metadata file
        if ! ensure_local_metadata_file "$file_metadata_local"; then
            log "[ERROR] Failed to prepare share: $current_share"
            exit 1
        fi

        # Download remote metadata
        if ! download_remote_metadata "$current_share" "$file_metadata_remote"; then
            log "[ERROR] Failed to prepare share: $current_share"
            exit 1
        fi
    done

    log ""
    log "[OK] All shares prepared successfully"
}

# Run main function only if executed directly (not sourced)
if [ "${0##*/}" = "prepare_rclone_shares.sh" ]; then
    prepare_rclone_shares
fi
