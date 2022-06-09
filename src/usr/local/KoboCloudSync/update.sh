#!/bin/sh
#
# Download the KoboRoot.tgz-file from GitHub and install on kobo

theGitHubURL="https://github.com/Atrium0804/KoboNextcloudsync/raw/main/KoboRoot.tgz"

#load config
. $(dirname $0)/config.sh

if [ "$device" == "dev"]
then
     theArchive="$WorkDir/KoboRoot.tgz"
else
    # theArchive="/tmp/KoboRoot.tgz"
    theArchive="/mnt/onboard/.Kobo/KoboRoot.tgz"
fi

# test network connection
case $device in
  "kobo") waitparm='-w' ;;
       *) waitparm='-i' ;;
esac
    echo "`$Dt` waiting for internet connection"
    r=1;i=0
    while [ $r != 0 ]; do
    if [ $i -gt 60 ]; then
        ping -c 1 $waitparm 3 aws.amazon.com >/dev/null 2>&1
        echo "`$Dt` error! no connection detected" 
        eval "$fbink \"error! no connection detected\" " 
        exit 1
    fi
    ping -c 1 $waitparm 3 aws.amazon.com >/dev/null 2>&1
    r=$? # get the exit-status of the previous cmd, 0=successful
    if [ $r != 0 ]; then sleep 1; fi
    i=$(($i + 1))
    done

# download KoboRoot.tgz from GitHub
echo "Downloading to $theArchive"
eval "$fbink \"Downloading update\" "
[ ! -e "$theExtractFolder" ] && mkdir -p "$theExtractFolder" >/dev/null 2>&1
wget -q $theGitHubURL -O $theArchive

# start udev_mount to create required folders
. $theExtractFolder/usr/local/KoboCloudSync/udev_mount.sh  >/dev/null 2>&1

eval "$fbink \"Perform a sync to apply te update.\" "