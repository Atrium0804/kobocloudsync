#!/bin/sh
#
# KoboCloudSync - Configuration
#
# Detects environment (dev/kobo), sets paths for binaries and folders,
# configures rclone options, and manages log file creation/cleanup.

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

log_folder=$installation_folder/logs

# create document_folders if they don't exist
mkdir -p "$document_folder"
mkdir -p "$log_folder"

scripts_folder=$(dirname $0)
rclone_config_file=$installation_folder/rclone.conf

# Set log files only if not already set (to prevent multiple log files when config is sourced multiple times)
if [ -z "$rcloneLogfile" ]; then
    rcloneLogfile=$installation_folder/rclone_$(date '+%Y%m%d_%H%M%S').log
fi

if [ -z "$scriptLogfile" ]; then
    scriptLogfile=$log_folder/kobocloudsync_$(date '+%Y%m%d_%H%M%S').log
fi

# Default rclone options (rclone uses -v for verbose logging, output to stdout/stderr)
rcloneOptions="--config=$rclone_config_file --no-check-certificate -v"

# Clean up log files older than 3 days
cleanup_old_logs() {
    find "$log_folder" -maxdepth 1 -name "kobocloudsync_*.log" -mtime +3 -delete 2>/dev/null
}


# Run cleanup only once (on first load)
if [ -z "$KOBOCLOUDSYNC_CONFIG_LOADED" ]; then
    cleanup_old_logs
    KOBOCLOUDSYNC_CONFIG_LOADED=1
fi

# Constants for metadata file naming
METADATA_LOCAL_SUFFIX="_metadata.local"
METADATA_REMOTE_SUFFIX="_metadata.remote"


##### dependencies #####
# set paths to binaries
rclone="$bin_folder/rclone/rclone$bin_ext"
kepubify="$bin_folder/kepubify/kepubify$bin_ext"
covergen="$bin_folder/kepubify/covergen$bin_ext"
seriesmeta="$bin_folder/kepubify/seriesmeta$bin_ext"

