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
# if grep -q '^UNINSTALL$' $rcloneConfig; then
#     echo "Uninstalling kobocloudsync!"
#     $HOME/uninstall.sh
#     exit 0
# fi

echo
echo "$YELLOW ====================================================== $NC"

# clear the rclone logfile
echo "`$Dt`" > "$rcloneLogfile"

# check working network connection
$SH_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ]; 
then 
    inkscr "$RED No network connection, aborting"
    exit 1
fi

#  get remote shares and download files
echo "$CYAN get shares $NC"
shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
if [ -z $shares ];
then 
    echo "$RED No shares in configfile $NC"
    exit 1
fi

# download remote files for each share
echo "$shares" |
while IFS= read -r currentShare; do
    inkscr "processing share $currentShare"
     $HOME/opt/downloadFiles.sh "$currentShare"
done

# check network again as the kobo might close the wifi after a while
# check working network connection
echo "$CYAN Pruning folders $NC"
$SH_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ]; 
then 
    incscr "$RED No network connection, aborting"
    exit 1
fi
$SH_HOME/pruneFolders.sh

# generate covers
inkscr "Generating Covers"
echo $covergen -g "$DocumentRoot"
$covergen -g "$DocumentRoot"

inkscr "kobocloudsync ready"

# remove the PID-file
rm $PIDfile