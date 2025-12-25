#!/bin/sh

# Remove subfolders from shares which have been deleted remotely
# This script checks for local subfolders that no longer exist in the remote listing
# and removes them to keep the local structure in sync with the remote

currentShare=$1
theRemoteFileListing=$2
theLocalFileListing=$3

# Load configuration to get document_folder path
. $(dirname $0)/config.sh

target_folder="$document_folder/$currentShare"

# # If target folder doesn't exist, nothing to clean up
# if [ ! -d "$target_folder" ]; then
#     echo "  [INFO] Target folder does not exist: $target_folder"
#     exit 0
# fi

# echo "  Checking for deleted subfolders in $currentShare..."

# # Get list of unique directories from remote listing
# # Extract paths, get directory names, sort and deduplicate
# remote_dirs=$(echo "$theRemoteFileListing" |
#               awk '{sub(/^[ \t]+/, ""); print}' |
#               cut -d ' ' -f 4- |
#               xargs -n1 dirname |
#               sort -u)

# # Find all local subdirectories
# find "$target_folder" -type d | while IFS= read -r local_dir; do
#     # Get relative path from target folder
#     relative_dir="${local_dir#$target_folder/}"

#     # Skip the root folder itself
#     if [ "$relative_dir" = "$target_folder" ]; then
#         continue
#     fi

#     # Check if this directory path exists in remote listing
#     if echo "$remote_dirs" | grep -q "^${relative_dir}$"; then
#         # Directory still exists remotely, keep it
#         :
#     else
#         # Directory no longer exists remotely, check if it has any files
#         if [ -z "$(ls -A "$local_dir")" ]; then
#             # Empty directory, safe to remove
#             echo "    [DELETE] Removing empty subfolder: $relative_dir"
#             rmdir "$local_dir"
#         else
#             # Directory has files, only remove if all files are orphaned
#             echo "    [WARN] Subfolder deleted remotely but contains local files: $relative_dir"
#             # Optionally: you could add logic here to remove if desired
#         fi
#     fi
# done

# echo "  [OK] Subfolder cleanup complete for $currentShare"
