#!/bin/sh

# This file contains locations (on the kobo-device)
# as wel as some general configurations

WorkDir=/mnt/onboard/.adds/kobocloudsync
DocumentRoot=/mnt/onboard/kobocloudsync

  rclone=$HOME/bin/rclone
kepubify=$HOME/bin/kepubify
covergen=$HOME/bin/covergen

Dt="date +%Y-%m-%d_%H:%M:%S"
device=kobo

# rclone parameters
rcloneConfig=$WorkDir/rclone.conf
rcloneLogfile=$WorkDir/rclone.log
rcloneOptions="--config=$rcloneConfig --log-file=$rcloneLogfile --no-check-certificate"