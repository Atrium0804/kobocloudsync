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
[ ! -e "$Lib" ] && mkdir -p "$Lib" >/dev/null 2>&1
[ ! -e "$DocumentRoot" ] && mkdir -p "$DocumentRoot" >/dev/null 2>&1


# call main script, output to log
 $KC_HOME/main.sh > $Logs/kobocloudsync.log 2>&1 &
