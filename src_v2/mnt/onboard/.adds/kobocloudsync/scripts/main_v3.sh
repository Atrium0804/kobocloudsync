#!/bin/sh
# KoboCloudSync v3 download script


# 1 Load the configuration which sets paths to binaries
# 2 check start conditions (dependencies, rclone config file, network)
# 3 from rclone config file, process each remote share:
#   - create a target folder for the share if it doesn't exist
#   - create an empty local metadata file if it doesn't exist
#   - list files in the share and download remote metadata
# 4  - update local metadata file: remove entries for files that no longer exist remotely
#     - donot remove metadata if kepubified files exist locally
#     - remove metadata if neither original nor kepubified file exists locally
# 5  - local deletions: if a file was deleted or change remotely, delete it locally
#           - delete the kepubified version if it exists
#           - delete the original file if it exists
#  6 - downloads remote files: if a file exists remotely but not locally, download it
#  7 - process downloaded files with kepubify
#     - if a .epub-files exits:
#        - convert to .kepub.epub with kepubify
#        - generate cover image with covergen
#        - generate series metadata with seriesmeta
#        - delete original .epub file

# script for downloading epubs to a kobo device from a remote location
# using rclone for file transfer and kepubify for converting epubs to kepub-epubs
# requires rclone and kepubify to be installed

echo "\nStarting KoboCloudSync download script\n"
verbose=true

# 1 Load the configuration which sets paths to binaries
scripts_folder=$(dirname $0)
. $scripts_folder/config.sh

# 2 check start conditions (dependencies, rclone config file, network)
. $scripts_folder/checkStartConditions.sh

# 3 prepare rclone shares: fetch shares, create folders, download metadata
# load the script and call the function
. $scripts_folder/prepare_rclone_shares.sh
prepare_rclone_shares

 # 4 process each share: update local metadata, remove deleted subfolders, sync files, kepubify
 . $scripts_folder/prune_local_metadata.sh
 prune_local_metadata

 # 5 process each share: delete local files that were removed or changed remotely
 . $scripts_folder/delete_removed_files.sh

 # 6 process each share: download missing files
 . $scripts_folder/download_missing_files.sh

# 7 process each share: kepubify downloaded files
. $scripts_folder/kepubify_downloaded_files.sh