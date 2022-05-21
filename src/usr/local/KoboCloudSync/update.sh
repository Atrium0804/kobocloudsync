#!/bin/sh
#
# Download the KoboRoot.tgz-file from GitHub and install on kobo

theGitHubURL="https://github.com/Atrium0804/KoboNextcloudsync/raw/main/KoboRoot.tgz"

#load config
. $(dirname $0)/config.sh

if uname -a | grep -q 'Darwin'
then
    #echo "MacOS detected"
    theArchive="/tmp/KoboRoot.tgz"
	theExtractFolder="/tmp/kobocloudsync"
else
    # theArchive="/tmp/KoboRoot.tgz"
    theArchive="/mnt/onboard/.Kobo/KoboRoot.tgz"
	theExtractFolder="/" # "" for root /
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
        exit 1
    fi
    ping -c 1 $waitparm 3 aws.amazon.com >/dev/null 2>&1
    r=$? # get the exit-status of the previous cmd, 0=successful
    if [ $r != 0 ]; then sleep 1; fi
    i=$(($i + 1))
    done

# download KoboRoot.tgz from GitHub
echo "Downloading to $theArchive"
[ ! -e "$theExtractFolder" ] && mkdir -p "$theExtractFolder" >/dev/null 2>&1
wget -q $theGitHubURL -O $theArchive


# # install: extract to root
# if tar -zxvf $theArchive --directory $theExtractFolder ; 
# 	then rm -f $theArchive
# fi

# start udev_mount to create required folders
echo "Starting udev_mount.sh"
. $theExtractFolder/usr/local/KoboCloudSync/udev_mount.sh  >/dev/null 2>&1

echo "Update completed. Perform a sync to start te update."