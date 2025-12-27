#!/bin/sh

# Configuration for KoboCloudSync

# determine if on development environment or kobo device
if uname -a | grep -q 'Darwin.*ARM64\|Darwin.*X86\|W64_NT'; then
    # development environment
    environment="dev"

    if uname -a | grep -q 'Darwin.*ARM64'; then
      # Mac M1
      arch="osx-arm64"
      ext=""
    elif uname -a | grep -q 'Darwin.*X86' ; then
      # Mac Intel
      arch="osx-amd64"
      ext=""
    elif uname -a | grep -q 'W64_NT' ; then
      # PC
      arch="win-amd64"
      ext=".exe"
    fi
else
    # kobo
    environment="kobo"
fi

# set folder locations based on environment
if [ "$environment" = "kobo" ]; then
    installation_folder=/mnt/onboard/.adds/kobocloudsync
    document_folder=$installation_folder/ebooks
    bin_folder=/mnt/onboard/.adds/kobocloudsync/bin
    bin_ext=""
elif [ "$environment" = "dev" ]; then
    installation_folder=C:/git/kobocloudsync/KoboFolder_DEV
    document_folder=$installation_folder/ebooks
    bin_ext=".exe"
    bin_folder=C:/git/kobocloudsync/bin/$arch
else
    echo "ERROR: unknown environment"
    exit 1
fi

scripts_folder=$(dirname $0)
rclone_config_file=$installation_folder/rclone.conf
rcloneLogfile=$installation_folder/rclone_$(date '+%Y%m%d_%H%M%S').log
scriptLogfile=$installation_folder/kobocloudsync_$(date '+%Y%m%d_%H%M%S').log

# Default rclone options
rcloneOptions="--config=$rclone_config_file --log-file=$rcloneLogfile --no-check-certificate"

# Clean up log files older than 3 days
cleanup_old_logs() {
    find "$installation_folder" -maxdepth 1 -name "kobocloudsync_*.log" -mtime +3 -delete 2>/dev/null
    find "$installation_folder" -maxdepth 1 -name "rclone_*.log" -mtime +3 -delete 2>/dev/null
}

# Logging function - prints to screen and log file
log() {
    echo "$@"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $@" >> "$scriptLogfile"
}

# Run cleanup on startup
cleanup_old_logs

# Constants for metadata file naming
METADATA_LOCAL_SUFFIX="_metadata_local.txt"
METADATA_REMOTE_SUFFIX="_metadata_remote.txt"

# create document_folder if it doesn't exist
mkdir -p "$document_folder"

##### dependencies #####
# set paths to binaries
rclone="$bin_folder/rclone/rclone$bin_ext"
kepubify="$bin_folder/kepubify/kepubify$bin_ext"
covergen="$bin_folder/kepubify/covergen$bin_ext"
seriesmeta="$bin_folder/kepubify/seriesmeta$bin_ext"

