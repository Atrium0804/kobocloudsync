#!/bin/sh

# initialisation of work dirs and config file

#load config
. $(dirname $0)/config.sh

#create work dirs if not exist
[ ! -e "$Logs" ] && mkdir -p "$Logs" >/dev/null 2>&1
[ ! -e "$WorkDir" ] && mkdir -p "$WorkDir" >/dev/null 2>&1

# echo "Locations:"
echo "Logs:    $Logs"
echo "WorkDir: $WorkDir"

# copy config file from template if exists, else create from 
echo "testing $UserConfig"
if [ ! -e $UserConfig ]; then
  if [ -e $ConfigTemplate ]; then
       echo "copying config-template"
       cp $ConfigTemplate $UserConfig
  else
    eco "generating config file"
    echo  "# Remove the # from the following line to uninstall KoboCloudSync" >> $UserConfig
    echo  "#UNINSTALL" >> $UserConfig
    echo  "# Remove the # from the following line to delete files when they are no longer on the remote server" >> $UserConfig
    echo  "#REMOVE_DELETED" >> $UserConfig
    echo  "#" >> $UserConfig
    echo  "# URL's to syncronize. Use the following format, separated by comma:" >> $UserConfig
    echo  "# Destination Folder, URL, Passwod (optional)" >> $UserConfig
  fi
fi