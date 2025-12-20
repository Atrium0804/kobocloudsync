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

# create document_folder if it doesn't exist
mkdir -p "$document_folder"

##### dependencies #####
# set paths to binaries
rclone="$bin_folder/rclone/rclone$bin_ext"
kepubify="$bin_folder/kepubify/kepubify$bin_ext"
covergen="$bin_folder/kepubify/covergen$bin_ext"
seriesmeta="$bin_folder/kepubify/seriesmeta$bin_ext"

# print config if verbose = true
if [ "$verbose" = "true" ]; then
    echo "Configuration loaded:"
    echo " Environment:        $environment"
    echo " Installation folder:$installation_folder"
    echo " Document folder:    $document_folder"
    echo " rclone:            $rclone"
    echo " kepubify:          $kepubify"
    echo " covergen:          $covergen"
    echo " seriesmeta:        $seriesmeta"
    echo ""
fi
