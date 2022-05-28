#!/bin/sh

# This file contains locations (on the kobo-device)
# as wel as some general configurations

WorkDir=/mnt/onboard/.adds/cloudsync
DocumentRoot=/mnt/onboard/

kepubify=$KC_HOME/kepubify/kepubify-linux-arm
covergen=$KC_HOME/kepubify/covergen-linux-arm
fbink="/usr/local/kfmon/bin/fbink -pmh -q -y -5" 

Dt="date +%Y-%m-%d_%H:%M:%S"
CURL="$KC_HOME/curl --cacert \"$KC_HOME/ca-bundle.crt\" "
device=kobo