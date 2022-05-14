#!/bin/sh

# initialisation of work dirs and config file

#load config
. $(dirname $0)/config.sh

#create work dirs if not exist
[ ! -e "$Logs" ] && mkdir -p "$Logs" >/dev/null 2>&1
[ ! -e "$Lib" ] && mkdir -p "$Lib" >/dev/null 2>&1
[ ! -e "$SD" ] && mkdir -p "$SD" >/dev/null 2>&1

# copy config file from template if exists, else create from 
if [ ! -e $UserConfig ]; then
  if [ -e $ConfigFile ]; then
    cp $ConfigFile $UserConfig
  else
    echo  "# Remove the # from the following line to uninstall KoboCloudSync" >> $UserConfig
    echo  "#UNINSTALL" >> $UserConfig
    echo  "# Remove the # from the following line to delete files when they are no longer on the remote server" >> $UserConfig
    echo  "#REMOVE_DELETED" >> $UserConfig
    echo  "" >> $UserConfig
    echo  "# URL's to syncronize. Use the following format, separated by comma:" >> $UserConfig
    echo  "# Destination Folder, URL, Passwod (optional)" >> $UserConfig
  fi
fi
