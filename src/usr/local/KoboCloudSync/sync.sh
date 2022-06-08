#!/bin/sh

#load config
. $(dirname $0)/config.sh


echo "`$Dt` start" 

# check working network connection
$KC_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ]; 
then 
    echo "$RED No network connection, aborting"
    exit 1
fi

#  get remote shares and download files
echo "$CYAN get shares $NC"
shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
echo "$shares" |
while IFS= read -r currentShare; do
    ./downloadFiles.sh "$currentShare"
done

# check network again as the kobo might close the wifi after a while
# check working network connection
echo "$CYAN Pruning folders $NC"
$KC_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ]; 
then 
    echo "$RED No network connection, aborting"
    exit 1
fi
$KC_HOME/pruneFolders.sh

# generate covers
$covergen -g $DocumentRoot


# rclone sync   - Make source and dest identical, modifying destination only.
# rclone ls     - List all the objects in the path with size and path.
# rclone rmdirs - Remove any empty directories under the path.

# ./rclone ls test:/ --config=rclone.config 
# ./rclone sync  test:/ ./data --config=rclone.config 