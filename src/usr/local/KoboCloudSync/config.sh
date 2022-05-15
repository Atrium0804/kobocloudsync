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

# bash colors
NOCOLOR='\033[0m'
     NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
cyan='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
