#!/bin/sh

# This script is called when a network-connection is detected
# Called by: /etc/udev/rules.d/97-kobocloud.rules
#
# Tasks:
#   load config.sh
#   create required directories if on exist
#   call main script
#

#load config
. $(dirname $0)/config.sh

# run shell in new session as udev kills slow scripts
# $0 - script location
# $@ - all parameters passed to the script
 if [ "$SETSID" != "1" ] && [ "$device" = "kobo" ];
 then
    SETSID=1 setsid "$0" "$@" &
    exit
 fi

#create work dirs
[ ! -e "$WorkDir" ] && mkdir -p "$WorkDir" >/dev/null 2>&1
[ ! -e "$DocumentRoot" ] && mkdir -p "$DocumentRoot" >/dev/null 2>&1

# copy config file from template if exists, else create new 
if [ ! -e $rcloneConfig ]; then
  inkscr "configure a cloud-connection in $rcloneconfig"
  echo "generating config file"
  echo "# Create a config file using rclone config: https://rclone.org/commands/rclone_config/" > $rcloneConfig
  echo "# Put the created file on this location">> $rcloneConfig
  echo "#" >> $rcloneConfig
fi

# start sync script, max 20min
timeout 20m  $HOME/opt/main.sh > $WorkDir/kobocloudsync.log 2>&1 &
