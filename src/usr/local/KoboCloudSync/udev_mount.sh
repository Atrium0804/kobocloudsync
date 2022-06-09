#!/bin/sh

# initialisation of work dirs and config file

#load config
. $(dirname $0)/config.sh

#create work dirs if not exist
[ ! -e "$WorkDir" ] && mkdir -p "$WorkDir" >/dev/null 2>&1

# copy config file from template if exists, else create from 
if [ ! -e $UserConfig ]; then
  if [ -e $ConfigTemplate ]; then
       echo "copying config-template"
       cp $ConfigTemplate $UserConfig
  else
    echo "generating config file"
    echo "# Create a config file using rclone config: https://rclone.org/commands/rclone_config/" > $UserConfig
    echo "# Put the contents of the created file in this file">> $UserConfig
    echo "#" >> $UserConfig
    echo  "# Remove the # from the following line to uninstall KoboCloudSync" >> $UserConfig
    echo  "#UNINSTALL" >> $UserConfig
  fi
fi