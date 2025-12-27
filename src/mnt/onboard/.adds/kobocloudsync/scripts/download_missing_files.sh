#!/bin/sh

# For each rclone share, download missing files from remote to local
# update local metadata accordingly

download_missing_files() {
    echo ""
    echo "----------------------------"
    echo "Downloading missing files from remote shares..."
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
        target_folder="$document_folder/$currentShare"
        # for each line in the remote metadata, check if the file exists locally
        # take into account kepubified files
        filename_metadata_remote="$document_folder/${currentShare}${METADATA_REMOTE_SUFFIX}"
        filename_metadata_local="$document_folder/${currentShare}${METADATA_LOCAL_SUFFIX}"

        while IFS= read -r line; do
            # extract the file path from the metadata line
            filePath=$(echo "$line" | awk '{for (i=4; i<=NF; i++) printf $i " "; print ""}' | sed 's/ *$//')
            localFile="$target_folder/$filePath"
            kepubFile="${localFile%.epub}.kepub.epub"
            # check if either the original file or the kepubified file exists locally
            if [ -f "$localFile" ] || [ -f "$kepubFile" ]; then
                # file exists locally, skip download
                :
            else
                # file does not exist locally, download it
                echo "  [DOWNLOAD] Fetching missing file: $filePath"
                # Create destination folder if needed
                mkdir -p "$(dirname "$localFile")"
                $rclone copy "$currentShare:/$filePath" "$(dirname "$localFile")" $rcloneOptions
                if [ $? -ne 0 ]; then
                    echo "    [ERROR] Failed to download file: $filePath"
                else
                    echo "    [OK] Downloaded: $filePath"
                    # Update local metadata: remove old entry if exists and add new one
                    grep -v -F "$filePath" "$filename_metadata_local" > "${filename_metadata_local}.tmp" 2>/dev/null || touch "${filename_metadata_local}.tmp"
                    echo "$line" >> "${filename_metadata_local}.tmp"
                    mv "${filename_metadata_local}.tmp" "$filename_metadata_local"
                    echo "    [UPDATE] Local metadata updated"
                fi
            fi
        done < "$filename_metadata_remote"
    done
}

# Run the function if script is executed directly
if [ "${0##*/}" = "download_missing_files.sh" ]; then
    download_missing_files
fi
