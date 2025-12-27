#!/bin/sh


# 5 process each share: delete local files that were removed or changed remotely:
#   for each line in the local metadata: check if the line exists in the remote file listing
#    if the line does not exist remotely, delete the local file including kepubified versions and
# remove the line from local metadata

delete_removed_files() {
    echo ""
    echo "----------------------------"
    echo "Deleting local files that were removed or changed remotely..."

    # Load configuration to get document_folder path
    scripts_folder=$(dirname $0)
    . $scripts_folder/config.sh
    # Fetch rclone shares
    . $scripts_folder/prepare_rclone_shares.sh
    shares=$(fetch_rclone_shares)
    # process each share
    shareCount=$(echo "$shares" | wc -l)
    shareNum=0
    echo "$shares" |
    while IFS= read -r currentShare; do
        shareNum=$((shareNum + 1))
        echo ""
        echo "[$shareNum/$shareCount] Processing share: $currentShare"
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
                echo "  [DELETE] Removed local file(s) for missing remote file: $filePath"
            fi
        done < "$filename_metadata_local"
        mv "$tempLocalMetadataFile" "$filename_metadata_local"
    done
}

# Run the function if script is executed directly
if [ "${0##*/}" = "delete_removed_files.sh" ]; then
    delete_removed_files
fi