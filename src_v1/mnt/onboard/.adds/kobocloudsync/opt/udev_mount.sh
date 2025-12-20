#!/bin/sh

# initialisation of work dirs and config file

# load config
. $(dirname $0)/config.sh
#create work dirs if not exist
[ ! -e "$WorkDir" ] && mkdir -p "$WorkDir" >/dev/null 2>&1
[ ! -e "$DocumentRoot" ] && mkdir -p "$DocumentRoot" >/dev/null 2>&1

# copy config file from template if exists, else create new 
if [ ! -e $rcloneConfig ]; then
    echo "generating config file"
    echo "# Create a config file using rclone config: https://rclone.org/commands/rclone_config/" > $rcloneConfig
    echo "# Put the created file on this location">> $rcloneConfig
    echo "#" >> $rcloneConfig
fi