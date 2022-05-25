#!/bin/sh

# This file contains locations (on the dev-machine)
# as wel as some general configurations

WorkDir=/tmp/kobocloudsync
DocumentRoot=$WorkDir/documents

kepubify=~/git/KoboNextcloudsync/DependenciesDev/kepubify-darwin-64bit/kepubify-darwin-64bit
covergen=~/git/KoboNextcloudsync/DependenciesDev/kepubify-darwin-64bit/covergen-darwin-64bit
kfmon=echo

Dt="date +%Y-%m-%d_%H:%M:%S"
CURL=/usr/bin/curl
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
