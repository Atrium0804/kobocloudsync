#!/bin/sh

# This file specifies the location of folders and
# binary-files for the dev-environment
# Supported:
#  Apple Mac Intel
#  Apple Mac M1
#  Windowss 64bit

     WorkDir=$KC_HOME/../../../../data
DocumentRoot=$WorkDir/documents

if uname -a | grep -q 'Darwin.*ARM64'; then 
  # Mac M1
      rclone=$KC_HOME/../../../../Sources_3rdParty/rclone-osx-arm64/rclone
    kepubify=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-arm64/kepubify
    covergen=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-arm64/covergen
          jq=$KC_HOME/../../../../Sources_3rdParty/jq/jq-osx-amd64
elif uname -a | grep -q 'Darwin.*X86' ; then
  # Mac Intel
      rclone=$KC_HOME/../../../../Sources_3rdParty/rclone-osx-amd64/rclone
    kepubify=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-64bit/kepubify
    covergen=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-64bit/covergen
          jq=$KC_HOME/../../../../Sources_3rdParty/jq/jq-osx-amd64
elif uname -a | grep -q 'W64_NT' ; then
  # PC
       rclone=$KC_HOME/../../../../Sources_3rdParty/rclone-win-amd64/rclone.exe
     kepubify=$KC_HOME/../../../../Sources_3rdParty/kepubify-win-amd64/kepubify.exe
     covergen=$KC_HOME/../../../../Sources_3rdParty/kepubify-win-amd64/covergen.exe
           jq=$KC_HOME/../../../../Sources_3rdParty/jq/jq-win64.exe
fi

Dt="date +%Y-%m-%d_%H:%M:%S"
device=dev

# bash colors
    NOCOLOR='\033[0m'
         NC='\033[0m'
        RED='\033[0;31m'
      GREEN='\033[0;32m'
       CYAN='\033[0;36m'
     YELLOW='\033[1;33m'

