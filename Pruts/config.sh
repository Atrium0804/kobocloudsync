#!/bin/bash

# this script is used to switch configuration
# depending on the device-type the script is run on (PC/Kobo)

# KC_HOME = locatoin where script is located
KC_HOME=$(dirname $0)
ConfigTemplate=$KC_HOME/KoboCloudSync.conf.tmpl


if uname -a | grep -q 'x86\|Darwin'
then
    #echo "PC detected"
    . $KC_HOME/config_pc.sh
else
    . $KC_HOME/config_kobo.sh
fi

UserConfig=$WorkDir/KoboCloudSync.conf
Logs=$WorkDir/log
RemoteFileList=$WorkDir/RemoteFilelist.txt
