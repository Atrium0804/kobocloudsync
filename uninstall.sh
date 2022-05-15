#!/bin/sh

# Uninstall kobocloud

rm -f /etc/udev/rules.d/97-kobocloudsync.rules
rm -rf /usr/local/kobocloud/sync
