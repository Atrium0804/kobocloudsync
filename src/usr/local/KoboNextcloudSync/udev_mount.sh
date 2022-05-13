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
    echo "# Add your URL to this file" > $UserConfig
    echo "URL=" > $UserConfig
    echo "username=" > $UserConfig
    echo "password=" > $UserConfig
    
    echo "# Remove the # from the following line to uninstall KoboCloud" >> $UserConfig
    echo "#UNINSTALL" >> $UserConfig
  fi
fi
