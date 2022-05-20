#!/bin/bash

# this script is used to switch configuration
# depending on the device-type the script is run on (PC/Kobo)

# KC_HOME = locatoin where script is located
KC_HOME=$(dirname $0)
ConfigTemplate=$KC_HOME/kobocloudsync.conf.tmpl


if uname -a | grep -q 'Darwin.*ARM64'
then 
    . $KC_HOME/config_MacM1.sh
elif uname -a | grep -q 'Darwin.*X86'
then
    . $KC_HOME/config_MacIntel.sh
else
    . $KC_HOME/config_kobo.sh
fi

UserConfig=$WorkDir/KoboCloudSync.conf
Logs=$WorkDir
RemoteFileList=$WorkDir/RemoteFilelist.txt
ExtensionPatterns=$KC_HOME/CompatibleExtensionPatterns.txt