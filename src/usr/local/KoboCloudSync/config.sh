#!/bin/bash

# this script is used to switch configuration
# depending on the device-type the script is run on (PC/Kobo)

# KC_HOME = locatoin where script is located
KC_HOME=$(dirname $0)
ConfigTemplate=$KC_HOME/kobocloudsync.conf.tmpl

if uname -a | grep -q 'Darwin.*ARM64\|Darwin.*X86\|W64_NT'; then 
    . $KC_HOME/config_dev.sh
else
    . $KC_HOME/config_kobo.sh
fi

# rclone parameters
rcloneConfig=$WorkDir/rclone.conf
rcloneLogfile=$WorkDir/rclone.log
rcloneOptions="--config=$rcloneConfig --log-file=$rcloneLogfile "

# file locations
UserConfig=$WorkDir/kobocloudsync.conf
RemoteFileList=$WorkDir/RemoteFilelist.txt

# misc
kepubRenamePattern='/.kepub.epub$/! s/\.epub$/\.kepub\.epub/i'  
ExtensionPatterns=$KC_HOME/CompatibleExtensionPatterns.txt

inkscr(){
  # Prints a line to the screen of the Kobo device
  # Long strings are truncated to prevent text wrapping
  TextToPrint="$1"
  maxchar=30
  TextToPrint=`echo $TextToPrint | cut -c 1-$maxchar`
  case $device in
  "kobo")  /usr/local/kfmon/bin/fbink -pm -q -y -7 "$TextToPrint";;
  "dev") echo "$TextToPrint" ;;
      *) echo "inkscr: error";;
  esac
}
