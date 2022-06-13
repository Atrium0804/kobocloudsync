#!/bin/sh

# This file contains locations (on the kobo-device)
# as wel as some general configurations

WorkDir=/mnt/onboard/.adds/kobocloudsync
DocumentRoot=/mnt/onboard/kobocloudsync

  rclone=$KC_HOME/bin/rclone
kepubify=$KC_HOME/bin/kepubify
covergen=$KC_HOME/bin/covergen

Dt="date +%Y-%m-%d_%H:%M:%S"
device=kobo