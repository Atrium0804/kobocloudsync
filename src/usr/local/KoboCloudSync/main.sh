#!/bin/sh


TEST=$1

#load config
. $(dirname $0)/config.sh
echo "${cyan}################## Main ##################${NC}"
# Read the configfile and 
# check if Kobocloud contains the line "UNINSTALL"
if grep -q '^UNINSTALL$' $UserConfig; then
    echo "Uninstalling KoboCloud!"
    $KC_HOME/uninstall.sh
    exit 0
fi

# Read the config file and check if Remove_deleted is set, 
# in that case, save the current file list
if grep -q "^REMOVE_DELETED$" $UserConfig; then
	echo "$WorkDir/filesList.log" > "$WorkDir/filesList.log"
fi

# test if the an internet-connection is available
# by pinging aws.amazon.com
if [ "$TEST" = "" ]
then
    echo "`$Dt` waiting for internet connection"
    r=1;i=0
    while [ $r != 0 ]; do
    if [ $i -gt 60 ]; then
        ping -c 1 -w 3 aws.amazon.com >/dev/null 2>&1
        echo "`$Dt` error! no connection detected" 
        exit 1
    fi
    ping -c 1 -w 3 aws.amazon.com >/dev/null 2>&1
    r=$? # get the exit-status of the previous cmd, 0=successful
    if [ $r != 0 ]; then sleep 1; fi
    i=$(($i + 1))
    done
fi

# process the config-file
IFS=',' #setting comma as delimiter  
while read line || [ -n "$line" ]; do
<<<<<<< HEAD
  echo "Reading $line"
  if echo "$line" | grep -q '^#'; then
    echo "Comment found"
=======
#   echo "Reading $line"
  if [ 1 -e 0 ] then echo "placeholder"
  elif echo "$line" | grep -q '^#'; then
    echo "${cyan}Comment found${NC}"
>>>>>>> 7ea70a903c10f653d3b7b977116e6645be17b62c
  elif echo "$line" | grep -q "^REMOVE_DELETED$"; then
	  echo "Files deleted on the server will be removed from this device."
  else
    # split the line in DestinationFolder, URL and password
<<<<<<< HEAD
    echo "${YELLOW}Reading $line${NC}"
=======
    echo "${cyan}Processing $line${NC}"
>>>>>>> 7ea70a903c10f653d3b7b977116e6645be17b62c
    read -a strarr <<<"$line"
    destFolder=${strarr[0]}
    url=${strarr[1]}  
    pwd=${strarr[2]}
<<<<<<< HEAD
    outDir="$DocumentRoot/$destFolder"
    echo "Processing: $url"
    # Get Files for specified URL
    $KC_HOME/getNextcloudFiles.sh "$url" "$outDir" "$pwd"
=======
    echo "Syncing $url to $destFolder"
    # if echo $url | grep -q '^https*://www.dropbox.com'; then # dropbox link?
    #   $KC_HOME/getDropboxFiles.sh "$url" "$Lib"
    # elif echo $url | grep -q '^DropboxApp:'; then # dropbox token
    #   token=`echo $url | sed -e 's/^DropboxApp://' -e 's/[[:space:]]*$//'`
    #   $KC_HOME/getDropboxAppFiles.sh "$token" "$Lib"
    # elif echo $url | grep -q '^https*://filedn.com'; then
    #   $KC_HOME/getpCloudFiles.sh "$url" "$Lib"
    # elif echo $url | grep -q '^https*://[^/]*pcloud'; then
    #   $KC_HOME/getpCloudFiles.sh "$url" "$Lib"
    # elif echo $url | grep -q '^https*://drive.google.com'; then
    #   $KC_HOME/getGDriveFiles.sh "$url" "$Lib"
    # elif echo $url | grep -q '^https*://app.box.com'; then
    #   $KC_HOME/getBoxFiles.sh "$url" "$Lib"
    # else
    #   $KC_HOME/getOwncloudFiles.sh "$url" "$Lib"
    # fi
>>>>>>> 7ea70a903c10f653d3b7b977116e6645be17b62c
  fi
done < $UserConfig


# # function to purge deleted files recursively
# purgeDeletedFiles() {
# for item in *; do
# 	if [ -d "$item" ]; then 
# 		(cd -- "$item" && purgeDeletedFiles)
# 	elif grep -Fq "$item" "$Lib/filesList.log"; then
# 		echo "$item found"
# 	else
# 		echo "$item not found, deleting"
# 		rm "$item"
# 	fi
# done
# }
# # purge files deleted from server
# if grep -q "^REMOVE_DELETED$" $UserConfig; then
# 	cd "$Lib"
# 	echo "Matching remote server"
# 	purgeDeletedFiles
# fi