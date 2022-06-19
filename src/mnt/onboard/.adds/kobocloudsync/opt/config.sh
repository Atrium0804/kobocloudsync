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

ConfigTemplate=$SH_HOME/kobocloudsync.conf.tmpl

# load development or kobo config
if uname -a | grep -q 'Darwin.*ARM64\|Darwin.*X86\|W64_NT'; then 
    . $SH_HOME/config_dev.sh
else
    . $SH_HOME/config_kobo.sh
fi

# file locations
RemoteFileList=$SH_HOME/RemoteFilelist

# misc
kepubRenamePattern='/.kepub.epub$/! s/\.epub$/\.kepub\.epub/i'  
ExtensionPatterns=$SH_HOME/CompatibleExtensionPatterns

# function to print to kobo-screen
inkscr(){
  # Prints a line to the screen of the Kobo device
  # Long strings are truncated to prevent text wrapping
  TextToPrint="$1"
  maxchar=40
  TextToPrint=`echo $TextToPrint | cut -c 1-$maxchar`
  case $device in
  "kobo")  /usr/local/kfmon/bin/fbink -pm -q -y -5 "$TextToPrint";;
  "dev") echo "$TextToPrint" ;;
      *) echo "inkscr: error";;
  esac
}