#!/bin/sh
# prune_local_metadata.sh
#
# Prune local metadata entries for files that no longer exist remotely,
# taking into account kepubified files.
## This script processes each rclone share defined in the rclone config file.
## For each share, it updates the local metadata file by removing entries for files
# that no longer exist remotely, unless a kepubified version of the file exists locally.
#           - remove metadata if neither original nor kepubified file exists locally
echo ""
echo "Pruning local metadata files..."
# Load configuration to get document_folder path
scripts_folder=$(dirname $0)
. $scripts_folder/config.sh

# Fetch rclone shares
. $scripts_folder/prepare_rclone_shares.sh
shares=$(fetch_rclone_shares)

# prune local metadata for each share
shareCount=$(echo "$shares" | wc -l)
shareNum=0
echo "$shares" |
while IFS= read -r currentShare; do
    shareNum=$((shareNum + 1))
    echo ""
    echo "[$shareNum/$shareCount] Processing share: $currentShare"
    # get the filename from local metadata file
    filename_metadata_local="$document_folder/${currentShare}${METADATA_LOCAL_SUFFIX}"

    # check if the file exists locally, check for .kepub.epub versions
    tempLocalMetadataFile="$document_folder/temp_${currentShare}${METADATA_LOCAL_SUFFIX}"
    touch "$tempLocalMetadataFile"
    while IFS= read -r line; do
        # extract the file path from the metadata line
        filePath=$(echo "$line" | awk '{for (i=4; i<=NF; i++) printf $i " "; print ""}' | sed 's/ *$//')
        originalFile="$document_folder/$currentShare/$filePath"
        kepubFile="${originalFile%.epub}.kepub.epub"

        # check if either the original file or the kepubified file exists locally
        if [ -f "$originalFile" ] || [ -f "$kepubFile" ]; then
            # keep the metadata entry
            echo "$line" >> "$tempLocalMetadataFile"
        else
            # remove the metadata entry (do not write it to temp file)
            echo "  [REMOVE] Pruning metadata for missing file: $filePath"
        fi
    done < "$filename_metadata_local"
    mv "$tempLocalMetadataFile" "$filename_metadata_local"
done