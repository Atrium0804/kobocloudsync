#!/bin/sh

# Description
# Syncs remote shares as defined in the rclone.conf file to a local destination
# Deletes local files removed from server
# Creates covers for downloaded books.
#
# uses:
# kepubify: https://github.com/pgaskin/kepubify
# jq:       https://github.com/stedolan/jq  
# rclone:   https://github.com/rclone/rclone

#load config
. $(dirname $0)/config.sh

echo "`$Dt` start" 

# check if Kobocloud contains the line "UNINSTALL"
# if grep -q '^UNINSTALL$' $UserConfig; then
#     echo "Uninstalling kobocloudsync!"
#     $KC_HOME/uninstall.sh
#     exit 0
# fi

# check working network connection
$KC_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ]; 
then 
    inkscr "$RED No network connection, aborting"
    exit 1
fi

#  get remote shares and download files
echo "$CYAN get shares $NC"
shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
echo "$shares" |
while IFS= read -r currentShare; do
    inkscr "processing share $currentShare"
    ./downloadFiles.sh "$currentShare"
done

# check network again as the kobo might close the wifi after a while
# check working network connection
echo "$CYAN Pruning folders $NC"
$KC_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ]; 
then 
    incscr "$RED No network connection, aborting"
    exit 1
fi
$KC_HOME/pruneFolders.sh

# generate covers
inkscr "Generating Covers"
$covergen -g $DocumentRoot