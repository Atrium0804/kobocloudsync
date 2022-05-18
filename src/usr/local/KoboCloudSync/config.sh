#!/bin/bash

# this script is used to switch configuration
# depending on the device-type the script is run on (PC/Kobo)

# KC_HOME = locatoin where script is located
KC_HOME=$(dirname $0)
ConfigTemplate=$KC_HOME/KoboCloudSync.conf.tmpl


if uname -a | grep -q 'Darwin.*ARM64'  # mac M1
then
    #echo "Mac M1 detected"
    kepubify=kepubify-darwin-arm64
    seriesmeta=seriesmeta-linux-arm
    covergen=covergen-darwin-arm64
    . $KC_HOME/config_dev.sh
elif uname -a | grep -q 'Darwin.*X86_64'  # mac intel
    kepubify=kepubify-darwin-arm
    seriesmeta=seriesmeta-darwin-arm
    covergen=covergen-darwin-arm
    #echo "PC detected"
    . $KC_HOME/config_dev.sh
else
    . $KC_HOME/config_kobo.sh
fi

UserConfig=$WorkDir/KoboCloudSync.conf
Logs=$WorkDir
RemoteFileList=$WorkDir/RemoteFilelist.txt
ExtensionPatterns=$KC_HOME/CompatibleExtensionPatterns.txt