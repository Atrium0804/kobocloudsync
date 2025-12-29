#!/bin/sh
#
# KoboCloudSync - Convert Downloaded Files
#
# Converts EPUB files to KEPUB format for better Kobo compatibility.
# Processes all .epub files (excluding .kepub.epub) in each share,
# converts them using kepubify, and removes originals after success.

# Load configuration to get document_folder path
scripts_folder=$(dirname $0)
. $scripts_folder/config.sh
. $scripts_folder/logger.sh

convert_downloaded_files() {
    log ""
    log "----------------------------"
    log "Kepubifying downloaded files..."

    # Fetch rclone shares
    . $scripts_folder/prepare_rclone_shares.sh
    shares=$(fetch_rclone_shares)

    # process each share
    shareCount=$(echo "$shares" | wc -l)
    shareNum=0
    while IFS= read -r currentShare; do
        shareNum=$((shareNum + 1))
        log ""
        log "[$shareNum/$shareCount] Processing share: $currentShare"
        shareFolder="$document_folder/$currentShare"
        # find all .epub files (not .kepub.epub) in the share folder
        find "$shareFolder" -type f -name "*.epub" ! -name "*.kepub.epub" |
        while IFS= read -r epubFile; do
            kepubFile="${epubFile%.epub}.kepub.epub"
            log "[KEPUBIFY] input:  $epubFile"
            log "[KEPUBIFY] output: $kepubFile"
            # convert to kepub.epub
            "$kepubify" --inplace -o "$(dirname "$epubFile")" "$epubFile"
            if [ $? -eq 0 ]; then
                rm -f "$epubFile"
                log "[OK] Kepubified and processed: $kepubFile"
            else
                log "[ERROR] Failed to kepubify: $epubFile" 1
            fi
        done
    done <<EOF
$shares
EOF
}

# Run the function if script is executed directly
if [ "${0##*/}" = "kepubify_downloaded_files.sh" ]; then
    convert_downloaded_files
fi
