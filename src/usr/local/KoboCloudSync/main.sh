#!/bin/sh


TEST=$1

#load config
. $(dirname $0)/config.sh

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
	echo "$Lib/filesList.log" > "$Lib/filesList.log"
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
#   echo "Reading $line"
  if echo "$line" | grep -q '^#'; then
    echo "${cyan}Comment found${NC}"
  elif echo "$line" | grep -q "^REMOVE_DELETED$"; then
	echo "Files deleted on the server will be removed from this device."
  else
    # split the line in DestinationFolder, URL and password
    echo "${0;34}Processing $line${1,37}"
    read -a strarr <<<"$line"
    destFolder=${strarr[0]}
    url=${strarr[1]}  
    pwd=${strarr[2]}
    echo "Getting $url"
    if echo $url | grep -q '^https*://www.dropbox.com'; then # dropbox link?
      $KC_HOME/getDropboxFiles.sh "$url" "$Lib"
    elif echo $url | grep -q '^DropboxApp:'; then # dropbox token
      token=`echo $url | sed -e 's/^DropboxApp://' -e 's/[[:space:]]*$//'`
      $KC_HOME/getDropboxAppFiles.sh "$token" "$Lib"
    elif echo $url | grep -q '^https*://filedn.com'; then
      $KC_HOME/getpCloudFiles.sh "$url" "$Lib"
    elif echo $url | grep -q '^https*://[^/]*pcloud'; then
      $KC_HOME/getpCloudFiles.sh "$url" "$Lib"
    elif echo $url | grep -q '^https*://drive.google.com'; then
      $KC_HOME/getGDriveFiles.sh "$url" "$Lib"
    elif echo $url | grep -q '^https*://app.box.com'; then
      $KC_HOME/getBoxFiles.sh "$url" "$Lib"
    else
      $KC_HOME/getOwncloudFiles.sh "$url" "$Lib"
    fi
  fi
done < $UserConfig