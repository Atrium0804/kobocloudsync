#!/bin/sh

#load config
. $(dirname $0)/config.sh

# Uninstall kobocloud
rm -rf /etc/udev/rules.d/97-kobocloudsync.rules
rm -rf /usr/local/kobocloudsync
rm -rf /mnt/onboard/.adds/nm
rm -rf $WorkDir
rm -rf $Logs
