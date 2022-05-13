# This file contains locations (on the kobo-device)
# as wel as some general configurations
#
# 2021-05-12 - SD-location disabled as we want the Library to be located directly in the root 

#!/bin/sh
Logs=/mnt/onboard/.adds/kobocloud
Lib=/mnt/onboard/NextCloud
# SD=/mnt/sd/kobocloud
UserConfig=/mnt/onboard/.adds/kobocloud/kobocloudrc
Dt="date +%Y-%m-%d_%H:%M:%S"
CURL="$KC_HOME/curl --cacert \"$KC_HOME/ca-bundle.crt\" "
Device=Kobo
