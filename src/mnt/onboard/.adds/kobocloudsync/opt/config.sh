#!/bin/bash

# this script is used to switch configuration
# depending on the device-type the script is run on (PC/Kobo)
#
# the inkscr function requires fbink to be installed
# which installs along with NickelMenu

# home: parent folder of the folder where the scripts are located
# workdir: = home dir on kobo device, 'data' in repository root on development environment
SH_HOME=$(dirname "$0")
HOME="$(cd $(dirname "$0")/..; pwd)"

# load development or kobo config
if uname -a | grep -q 'Darwin.*ARM64\|Darwin.*X86\|W64_NT'; then
    . $SH_HOME/config_dev.sh
else
    . $SH_HOME/config_kobo.sh
fi

# file locations
RemoteFileList=$WorkDir/RemoteFilelist
PIDfile=$WorkDir/kobocloudsync.pid
booksdownloadedTrigger=$WorkDir/booksdownloaded.trigger
rcloneConfig=$WorkDir/rclone.conf
rcloneLogfile=$WorkDir/rclone.log

# logging-options
rcloneOptions="--config=$rcloneConfig --log-file=$rcloneLogfile --no-check-certificate"

# misc
kepubRenamePattern='/.kepub.epub$/! s/\.epub$/\.kepub\.epub/i'
ExtensionPatterns=$SH_HOME/CompatibleExtensionPatterns
isBooksDownloaded=0

# function to print to kobo-screen
inkscr(){
  # Prints a line to the screen of the Kobo device
  # Long strings are truncated to prevent text wrapping
  TextToPrint="$1"
  maxchar=60
  TextToPrintShort=`echo $TextToPrint | cut -c 1-$maxchar`
  case $device in
  "kobo")

        /usr/local/kfmon/bin/fbink -pm -q -y -5 "$TextToPrintShort"
         # /mnt/onboard/.adds/fbink/bin/fbink  -pm -q -y -5 --font THIN "$TextToPrintShort"
        echo "$TextToPrint"
  ;;
  "dev") echo "$TextToPrint" ;;
      *) echo "inkscr: error";;
  esac
}