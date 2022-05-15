#!/bin/sh

#load config
. $(dirname $0)/config.sh

# Uninstall kobocloud
rm -f /etc/udev/rules.d/97-kobocloudsync.rules
rm -rf /usr/local/kobocloudsync
rm -rf /usr/local/kobocloudsync
rm -rf $WorkDir
