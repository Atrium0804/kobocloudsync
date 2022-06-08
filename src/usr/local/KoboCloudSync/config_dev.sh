#!/bin/sh

# This file contains locations (on the dev-machine)
# as wel as some general configurations

     WorkDir=$KC_HOME/../../../../data
DocumentRoot=$WorkDir/documents
      rclone=$KC_HOME/../../../../Sources_3rdParty/rclone-osx-amd64/rclone
    kepubify=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-64bit/kepubify
    covergen=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-64bit/covergen
          jq=$KC_HOME/../../../../Sources_3rdParty/jq/jq-osx-amd64
       fbink=echo
 
if uname -a | grep -q 'Darwin.*ARM64'; then 
  # Mac M1
     WorkDir=$KC_HOME/../../../../data
DocumentRoot=$WorkDir/documents
      rclone=$KC_HOME/../../../../Sources_3rdParty/rclone-osx-arm64/rclone
    kepubify=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-arm64/kepubify
    covergen=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-arm64/covergen
          jq=$KC_HOME/../../../../Sources_3rdParty/jq/jq-osx-amd64
       fbink=echo
elif uname -a | grep -q 'Darwin.*X86' ; then
  # Mac Intel
     WorkDir=$KC_HOME/../../../../data
DocumentRoot=$WorkDir/documents
      rclone=$KC_HOME/../../../../Sources_3rdParty/rclone-osx-amd64/rclone
    kepubify=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-64bit/kepubify
    covergen=$KC_HOME/../../../../Sources_3rdParty/kepubify-osx-64bit/covergen
          jq=$KC_HOME/../../../../Sources_3rdParty/jq/jq-osx-amd64
       fbink=echo
elif uname -a | grep -q 'W64_NT' ; then
  # PC
      WorkDir=$KC_HOME/../../../../data
 DocumentRoot=$WorkDir/documents
       rclone=$KC_HOME/../../../../Sources_3rdParty/rclone-win-amd64/rclone.exe
     kepubify=$KC_HOME/../../../../Sources_3rdParty/kepubify-win-amd64/kepubify.exe
     covergen=$KC_HOME/../../../../Sources_3rdParty/kepubify-win-amd64/covergen.exe
       fbink=echo
           jq=$KC_HOME/../../../../Sources_3rdParty/jq/jq-win64.exe
fi


Dt="date +%Y-%m-%d_%H:%M:%S"
device=dev

# bash colors
    NOCOLOR='\033[0m'
         NC='\033[0m'
        RED='\033[0;31m'
      GREEN='\033[0;32m'
     ORANGE='\033[0;33m'
       BLUE='\033[0;34m'
     PURPLE='\033[0;35m'
       CYAN='\033[0;36m'
       cyan='\033[0;36m'
  LIGHTGRAY='\033[0;37m'
   DARKGRAY='\033[1;30m'
   LIGHTRED='\033[1;31m'
 LIGHTGREEN='\033[1;32m'
     YELLOW='\033[1;33m'
  LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
  LIGHTCYAN='\033[1;36m'
      WHITE='\033[1;37m'
