#!/bin/sh

# This file contains locations (on the kobo-device)
# as wel as some general configurations

WorkDir=/mnt/onboard/.adds/KoboCloudSync
DocumentRoot=/mnt/onboard/
UserConfig=$WorkDir/KoboCloudSync.conf
Logs=$WorkDir/log
Dt="date +%Y-%m-%d_%H:%M:%S"
CURL="$KC_HOME/curl --cacert \"$KC_HOME/ca-bundle.crt\" "
Device=Kobo
