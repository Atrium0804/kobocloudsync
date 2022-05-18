#!/bin/sh
#
# Download the KoboRoot.tgz-file from GitHub and install on kobo

theGitHubURL="https://github.com/Atrium0804/KoboNextcloudsync/raw/main/KoboRoot.tgz"
theArchive="/tmp/KoboRoot.tgz"

if uname -a | grep -q 'x86\|Darwin'
then
    #echo "PC detected"
    theArchive="/tmp/KoboRoot.tgz"
	theExtractFolder="/tmp/kobotest"
else
    theArchive="/tmp/KoboRoot.tgz"
	theExtractFolder="/"
fi
[ ! -e "$theExtractFolder" ] && mkdir -p "$theExtractFolder" >/dev/null 2>&1

# download from GitHub
wget $theGitHubURL -O $theArchive

# install: extract to root
if tar -zxvf $theArchive --directory $theExtractFolder ; 
	then rm -f $theArchive
fi
. $theExtractFolder/usr/local/kobocloudsync/udev_mount.sh
