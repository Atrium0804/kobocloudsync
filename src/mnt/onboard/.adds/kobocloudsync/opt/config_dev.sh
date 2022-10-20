#!/bin/sh

# This file specifies the location of folders and
# binary-files for the dev-environment
# Supported:
#  Apple Mac Intel
#  Apple Mac M1
#  Windowss 64bit


repo=`echo "$(git rev-parse --show-toplevel)"`
     WorkDir=$repo/data
DocumentRoot=$WorkDir/documents


if uname -a | grep -q 'Darwin.*ARM64'; then 
  # Mac M1
  arch="osx-arm64"
  ext=""
elif uname -a | grep -q 'Darwin.*X86' ; then
  # Mac Intel
  arch="osx-amd64"
  ext=""
elif uname -a | grep -q 'W64_NT' ; then
  # PC
  arch="win-amd64"
  ext=".exe"
else
  echo "ERROR: unknown architecture"
  exit 1
fi

# set paths to to binaries
  rclone="$repo/bin/$arch/rclone/rclone$ext"
kepubify="$repo/bin/$arch/kepubify/kepubify$ext"
covergen="$repo/bin/$arch/kepubify/covergen$ext"
seriesmeta="$repo/bin/$arch/kepubify/seriesmeta$ext"
Dt="date +%Y-%m-%d_%H:%M:%S"
device=dev

# bash colors
    NOCOLOR='\033[0m'
         NC='\033[0m'
        RED='\033[0;31m'
      GREEN='\033[0;32m'
       CYAN='\033[0;36m'
     YELLOW='\033[1;33m'