#!/bin/sh
#
# KoboCloudSync - Prepare Rclone Shares
#
# Fetches remote shares from rclone config and prepares sync environment:
#   - Creates target folders for each share
#   - Initializes local metadata files
#   - Downloads remote metadata listings
#   - Cleans up obsolete share folders

# Load configuration
scripts_folder=$(dirname $0)
. $scripts_folder/config.sh
. $scripts_folder/logger.sh


# Function: Fetch list of remote shares from rclone config
fetch_rclone_shares() {
    local shares
    shares=$("$rclone" listremotes --config="$rclone_config_file" --no-check-certificate 2>/dev/null | sed 's/://')

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
        log "[INFO] Document folder does not exist yet: $document_folder"
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
            log "[DELETE] Removing target folder for deleted share: $folder_name"
            rm -rf "$local_dir"
            rm -f "$document_folder/${folder_name}${METADATA_LOCAL_SUFFIX}"
            rm -f "$document_folder/${folder_name}${METADATA_REMOTE_SUFFIX}"
        fi
    done

    log "[OK] Target folder cleanup complete"
}

# Function: Create target folder if it doesn't exist
ensure_target_folder() {
    local target_folder="$1"

    if [ ! -d "$target_folder" ]; then
        log "  Creating target folder: $target_folder"
        mkdir -p "$target_folder"
        if [ $? -ne 0 ]; then
            log "[ERROR] Failed to create target folder: $target_folder" 1
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
            log "[ERROR] Failed to create metadata file: $metadata_file" 1
            return 1
        fi
    fi
    return 0
}

# Function: Download remote metadata for a share
download_remote_metadata() {
    local share="$1"
    local metadata_file="$2"
    local extension_patterns="$installation_folder/extensionpatterns.cfg"

    log "  Fetching remote metadata for $share..."
    "$rclone" lsl "$share":/ --config="$rclone_config_file" --no-check-certificate 2>/dev/null > "${metadata_file}.tmp"

    if [ $? -ne 0 ]; then
        log "  [ERROR] Failed to fetch remote metadata for $share" 1
        rm -f "${metadata_file}.tmp"
        return 1
    fi

    # Filter by compatible extensions if config exists
    if [ -f "$extension_patterns" ]; then
        local theListing=$(cat "${metadata_file}.tmp")

        # Log files that will be filtered out
        local removed_files=$(echo "$theListing" | grep -v -i -f "$extension_patterns")
        if [ -n "$removed_files" ]; then
            local removed_count=$(echo "$removed_files" | wc -l)
            log "  [FILTER] Removing $removed_count incompatible file(s) from metadata" 2
            echo "$removed_files" | while IFS= read -r removed_line; do
                local removed_file=$(echo "$removed_line" | awk '{for (i=4; i<=NF; i++) printf $i " "; print ""}' | sed 's/ *$//')
                log "    [SKIP] $removed_file" 4
            done
        fi

        # Filter to keep only compatible files
        theListing=$(echo "$theListing" | grep -i -f "$extension_patterns")
        echo "$theListing" > "$metadata_file"
        rm -f "${metadata_file}.tmp"
        log "  [OK] Remote metadata filtered by extension patterns"
    else
        mv "${metadata_file}.tmp" "$metadata_file"
        log "  [OK] Remote metadata retrieved (no filtering)"
    fi

    return 0
}

# Main function: Prepare all rclone shares
prepare_rclone_shares() {
    log ""
    log "Preparing rclone shares:"
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

    while IFS= read -r current_share; do
        share_num=$((share_num + 1))

        log ""
        log "[$share_num/$share_count] Processing share: $current_share"

        local target_folder="$document_folder/$current_share"
        local file_metadata_local="$document_folder/${current_share}${METADATA_LOCAL_SUFFIX}"
        local file_metadata_remote="$document_folder/${current_share}${METADATA_REMOTE_SUFFIX}"

        # Create target folder
        if ! ensure_target_folder "$target_folder"; then
            log "[ERROR] Failed to prepare share: $current_share" 1
            exit 1
        fi

        # Create local metadata file
        if ! ensure_local_metadata_file "$file_metadata_local"; then
            log "[ERROR] Failed to prepare share: $current_share" 1
            exit 1
        fi

        # Download remote metadata
        if ! download_remote_metadata "$current_share" "$file_metadata_remote"; then
            log "[ERROR] Failed to prepare share: $current_share" 1
            exit 1
        fi
    done <<EOF
$shares
EOF

    log ""
    log "[OK] All shares prepared successfully"
}

# Run main function only if executed directly (not sourced)
if [ "${0##*/}" = "prepare_rclone_shares.sh" ]; then
    prepare_rclone_shares
fi
