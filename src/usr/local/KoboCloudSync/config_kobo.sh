#!/bin/sh

# This file contains locations (on the kobo-device)
# as wel as some general configurations


Logs=/mnt/onboard/.adds/KoboCloudSync
Lib=/mnt/onboard/.adds/KoboCloudSync
UserConfig=/mnt/onboard/.adds/KoboCloudSync/KoboCloudSync.conf
Dt="date +%Y-%m-%d_%H:%M:%S"
CURL="$KC_HOME/curl --cacert \"$KC_HOME/ca-bundle.crt\" "
Device=Kobo
