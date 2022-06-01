#!/bin/sh

# This file contains locations (on the kobo-device)
# as wel as some general configurations

WorkDir=/mnt/onboard/.adds/cloudsync
DocumentRoot=/mnt/onboard/

  rclone=$KC_HOME/bin/rclone
kepubify=$KC_HOME/bin/kepubify
covergen=$KC_HOME/bin/covergen

fbink="/usr/local/kfmon/bin/fbink -pm -q -y -7" 

Dt="date +%Y-%m-%d_%H:%M:%S"
device=kobo