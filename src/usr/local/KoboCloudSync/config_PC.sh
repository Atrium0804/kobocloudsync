#!/bin/sh

# This file contains locations (on the dev-machine)
# as wel as some general configurations


      WorkDir=$KC_HOME/../../../../data
 DocumentRoot=$WorkDir/documents
       rclone=$KC_HOME/../../../../Sources_3rdParty/rclone-win-amd64/rclone.exe
     kepubify=$KC_HOME/../../../../Sources_3rdParty/kepubify_win_amd64/kepubify.exe
     covergen=$KC_HOME/../../../../Sources_3rdParty/kepubify_win_amd64/covergen.exe
       fbink=echo
           jq=$KC_HOME/../../../../Sources_3rdParty/jq/jq-win64.exe

Dt="date +%Y-%m-%d_%H:%M:%S"
device=dev

# bash colors
    NOCOLOR='\033[0m'
         NC='\033[0m'
        RED='\033[0;31m'
      GREEN='\033[0;32m'
     YELLOW='\033[1;33m'
     ORANGE='\033[0;33m'
       BLUE='\033[0;34m'
     PURPLE='\033[0;35m'
       CYAN='\033[0;36m'
      WHITE='\033[1;37m'