#!/bin/sh

#load config
. $(dirname $0)/config.sh

# Uninstall kobocloud including data
rm -rf /etc/udev/rules.d/97-kobocloudsync.rules
rm -rf /usr/local/kobocloudsync
rm -rf /mnt/onboard/.adds/nm/kobocloudsync
rm -rf $WorkDir
rm -rf $DocumentRoot
