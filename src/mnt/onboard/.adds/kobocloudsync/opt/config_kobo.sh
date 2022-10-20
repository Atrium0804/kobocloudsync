#!/bin/sh

# This file contains locations (on the kobo-device)
# as wel as some general configurations

WorkDir=/mnt/onboard/.adds/kobocloudsync
DocumentRoot=/mnt/onboard/kobocloudsync

  rclone=$HOME/bin/rclone
kepubify=$HOME/bin/kepubify
covergen=$HOME/bin/covergen
seriesmeta=$HOME/bin/seriesmeta

Dt="date +%Y-%m-%d_%H:%M:%S"
device=kobo