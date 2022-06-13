#!/bin/sh

#load config
. $(dirname $0)/config.sh

# Uninstall kobocloud excluding data (as the DocumentRoot might be /mnt/onboard/)
HOME=$1
if [ -z "$HOME" ] || [ "$HOME" = "/mnt/onboard"] || [ -z "$WorkDir" ] || [ "$WorkDir" = "/mnt/onboard"]
then 
	# don't delete when HOME is empty on the KOBOeReader-root
	echo "home is empty"
else 
	incscr "uninstalling (dry-run"
	# rm -rf /etc/udev/rules.d/97-kobocloudsync.rules
	# rm -rf $HOME
	# rm -rf /mnt/onboard/.adds/nm/kobocloudsync
	# rm -rf $WorkDir
fi


