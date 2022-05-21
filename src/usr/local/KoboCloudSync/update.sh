#!/bin/sh
#
# Download the KoboRoot.tgz-file from GitHub and install on kobo

theGitHubURL="https://github.com/Atrium0804/KoboNextcloudsync/raw/main/KoboRoot.tgz"
theArchive="/tmp/KoboRoot.tgz"

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


# download KoboRoot.tgz from GitHub
[ ! -e "$theExtractFolder" ] && mkdir -p "$theExtractFolder" >/dev/null 2>&1
wget $theGitHubURL -O $theArchive


# # install: extract to root
# if tar -zxvf $theArchive --directory $theExtractFolder ; 
# 	then rm -f $theArchive
# fi
# start udev_mount to create required foldres
. $theExtractFolder/usr/local/KoboCloudSync/udev_mount.sh