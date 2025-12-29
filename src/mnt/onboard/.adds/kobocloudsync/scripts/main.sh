#!/bin/sh
#
# KoboCloudSync v3 - Main Script
#
# Synchronizes ebooks from cloud storage (via rclone) to Kobo e-reader.
# Converts EPUB files to KEPUB format for better Kobo compatibility.
#
# Process flow:
#   1. Check dependencies, rclone config, and network connectivity
#   2. Prepare rclone shares: fetch metadata, create folders
#   3. Prune local metadata for remotely deleted files
#   4. Delete local files that were removed remotely
#   5. Download missing files from remote shares
#   6. Convert downloaded EPUBs to KEPUB format
#   7. Trigger library rescan if changes were made

# script for downloading epubs to a kobo device from a remote location
# using rclone for file transfer and kepubify for converting epubs to kepub-epubs
# requires rclone and kepubify to be installed

# Verbosity levels: 1=errors, 2=warnings, 3=info, 4=debug
verbosity=3
isRefreshLibrary=false

# 1 Load the configuration which sets paths to binaries
scripts_folder=$(dirname $0)
. $scripts_folder/config.sh
. $scripts_folder/logger.sh

log "\nStarting KoboCloudSync download script\n"

# print config if verbosity >= 4
if [ "$verbosity" -ge 4 ]; then
    log "Configuration loaded:" 4
    log " Environment:        $environment" 4
    log " Installation folder:$installation_folder" 4
    log " Document folder:    $document_folder" 4
    log " rclone:            $rclone" 4
    log " kepubify:          $kepubify" 4
    log " covergen:          $covergen" 4
    log " seriesmeta:        $seriesmeta" 4
    log "" 4
fi


# 2 check start conditions (dependencies, rclone config file, network)
progress 1 7 "Checking...     "
. $scripts_folder/checkStartConditions.sh

log ""
log "----------------------------"
log "Checking start conditions..." 3

# Check dependencies
if ! checkDependencies; then
    log "ERROR: Dependency check failed" 1
    exit 1
fi
# Check rclone config
if ! checkRcloneConfig; then
    log "ERROR: Rclone config check failed" 1
    exit 1
fi
# Check network connection
if ! checkNetwork; then
    log "ERROR: Network check failed" 1
    exit 1
fi
log "All start conditions met, proceeding" 3

# 3 prepare rclone shares: fetch shares, create folders, download metadata
# load the script and call the function

progress 1 7 "Starting...     "
. $scripts_folder/prepare_rclone_shares.sh
prepare_rclone_shares

# 4 process each share: update local metadata, remove deleted subfolders, sync files, kepubify
progress 2 7 "Housekeeping...       "
 . $scripts_folder/prune_local_metadata.sh
 prune_local_metadata

# 5 process each share: delete local files that were removed or changed remotely
    progress 3 7 "Removing...     "
 . $scripts_folder/delete_removed_files.sh
 delete_removed_files

 # 6 process each share: download missing files
progress 4 7 "Downloading...  "
 . $scripts_folder/download_missing_files.sh
 download_missing_files

# 7 process each share: kepubify downloaded files
progress 5 7 "Converting...          "
. $scripts_folder/convert_downloaded_files.sh
convert_downloaded_files

log ""
log "----------------------------"
log "Generating covers ..." 3
progress 6 7 "Generating covers.."
$covergen "/mnt/onboard" > /dev/null
log ""
log "----------------------------"
log "Generating series metadata..." 3
progress 6 7 "Generating series metadata.."
$seriesmeta "/mnt/onboard" > /dev/null


if [ "$isRefreshLibrary" = "true" ]; then
    progress 7 7 "Rescan library!         "
    log "\nCompleted - Refresh your library..."
else
    progress 7 7 "No changes.           "
fi