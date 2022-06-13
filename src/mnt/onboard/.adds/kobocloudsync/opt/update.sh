#!/bin/sh
#
# Download the KoboRoot.tgz-file from GitHub and install on kobo
# on the Kobo the KoboRoot.tgz is downloaded to the .Kobo folder
# performing a regular sync using the sync-button on the top of the screen
# will trigger the regular installation of the software

theGitHubURL="https://github.com/Atrium0804/KoboNextcloudsync/raw/main/KoboRoot.tgz"

#load config
. $(dirname $0)/config.sh

if [ "$device" == "dev"]
then
     theArchive="$WorkDir/KoboRoot.tgz"
else
    theArchive="/mnt/onboard/.Kobo/KoboRoot.tgz"
fi

# check working network connection
$SH_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ]; 
then 
    inkscr "$RED No network connection, aborting"
    exit 1
fi

# download KoboRoot.tgz from GitHub
echo "Downloading to $theArchive"
incsrc "Downloading update"
[ ! -e "$theExtractFolder" ] && mkdir -p "$theExtractFolder" >/dev/null 2>&1
wget -q $theGitHubURL -O $theArchive

# start udev_mount to create required folders
# . $theExtractFolder/usr/local/KoboCloudSync/udev_mount.sh  >/dev/null 2>&1

incscr "Perform a sync to apply te update."