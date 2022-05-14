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
  echo "Reading $line"
  if echo "$line" | grep -q '^#'; then
    echo "Comment found"
  elif echo "$line" | grep -q "^REMOVE_DELETED$"; then
	echo "Files deleted on the server will be removed from this device."
  else
    # split the line in DestinationFolder, URL and password
    echo "${YELLOW}Reading $line${NC}"
    read -a strarr <<<"$line"
    destFolder=${strarr[0]}
    url=${strarr[1]}  
    pwd=${strarr[2]}
    outDir="$DocumentRoot/$destFolder"
    echo "Processing: $url"
    # Get Files for specified URL
    $KC_HOME/getNextcloudFiles.sh "$url" "$outDir" "$pwd"
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