#!/bin/sh
#
# KoboCloudSync - Delete Removed Files
#
# Deletes local files that were removed or changed remotely by comparing
# local and remote metadata. Removes both original and kepubified versions,
# updates local metadata, and cleans up empty directories.

# Load configuration
scripts_folder=$(dirname $0)
. $scripts_folder/config.sh
. $scripts_folder/logger.sh

# Function: Remove empty directories recursively
remove_empty_directories() {
    local base_dir="$1"

    # Find all directories, sorted by depth (deepest first)
    find "$base_dir" -type d | sort -r | while IFS= read -r dir; do
        # Skip the base directory itself
        if [ "$dir" = "$base_dir" ]; then
            continue
        fi

        # Check if directory is empty (no files or subdirectories)
        if [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
            rmdir "$dir" 2>/dev/null && log "  [CLEANUP] Removed empty directory: ${dir#$document_folder/}"
        fi
    done
}

delete_removed_files() {
    log ""
    log "----------------------------"
    log "Deleting local files that were removed or changed remotely..."




    # Fetch rclone shares
    . $scripts_folder/prepare_rclone_shares.sh
    shares=$(fetch_rclone_shares)

    # process each share:
    shareCount=$(echo "$shares" | wc -l)
    shareNum=0
    while IFS= read -r currentShare; do
        shareNum=$((shareNum + 1))
        log ""
        log "[$shareNum/$shareCount] Processing share: $currentShare"
        filename_metadata_local="$document_folder/${currentShare}${METADATA_LOCAL_SUFFIX}"
        filename_metadata_remote="$document_folder/${currentShare}${METADATA_REMOTE_SUFFIX}"
        tempLocalMetadataFile="$document_folder/temp_${currentShare}${METADATA_LOCAL_SUFFIX}"
        touch "$tempLocalMetadataFile"
        while IFS= read -r line; do
            # check if the line exists in remote metadata
            if grep -qF "$line" "$filename_metadata_remote"; then
                # line exists remotely, keep it
                echo "$line" >> "$tempLocalMetadataFile"
            else
                # line does not exist remotely, delete local file(s) and do not write line to temp file
                filePath=$(echo "$line" | awk '{for (i=4; i<=NF; i++) printf $i " "; print ""}' | sed 's/ *$//')
                originalFile="$document_folder/$currentShare/$filePath"
                kepubFile="${originalFile%.epub}.kepub.epub"
                rm -f "$originalFile" "$kepubFile"
                log "[DELETE] Removed local file(s) for missing remote file: $filePath"
                isRefreshLibrary=true
            fi
        done < "$filename_metadata_local"
        mv "$tempLocalMetadataFile" "$filename_metadata_local"

        # Remove empty directories in the share folder
        log "Cleaning up empty directories in share: $currentShare"
        remove_empty_directories "$document_folder/$currentShare"
    done <<EOF
$shares
EOF
}



# Run the function if script is executed directly
if [ "${0##*/}" = "delete_removed_files.sh" ]; then
    delete_removed_files
fi