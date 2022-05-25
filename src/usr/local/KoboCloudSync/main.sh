#!/bin/sh

TEST=$1

# v2 cut ipv <<<

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

# Starting new filelist
# add filelist itself to prevent from pruning
echo "$RemoteFileList" > "$RemoteFileList"

# test if the an internet-connection is available
# by pinging aws.amazon.com
case $device in
  "kobo") waitparm='-w' ;;
       *) waitparm='-i' ;;
esac

if [ "$TEST" = "" ]
then
    echo "`$Dt` waiting for internet connection"
    eval "$fbink \"waiting for internet connection\" "
    r=1;i=0
    while [ $r != 0 ]; do
    if [ $i -gt 60 ]; then
        ping -c 1 $waitparm 3 aws.amazon.com #>/dev/null 2>&1
        echo "`$Dt` error! no connection detected" 
        "$fbink  \"error! no connection detected\" " 
        exit 1
    fi
    ping -c 1 $waitparm 3 aws.amazon.com #>/dev/null 2>&1
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
   exec # comment found, do nothing
  elif [ "$line" = "" ]; then
    exec # empty line
  elif echo "$line" | grep -q "^REMOVE_DELETED$"; then
	  echo "Files deleted on the server will be removed from this device."
  else
    echo "$YELLOW processing: $line $NC"
    # split the line in DestinationFolder, URL and password
 	  destFolder=$(echo "$line" | cut -d, -f1)
	  url=$(echo "$line" | cut -d, -f2)
	  pwd=$(echo "$line" | cut -d, -f3-)   
    pwd=$(echo "$pwd" | tr -d [:blank:]) # trim spacees
    # echo "-${pwd}-"
    destFolderAbsolute="$DocumentRoot/$destFolder"
    eval "$fbink \"Processing $destFolder\" " 
    $KC_HOME/getNextcloudFiles.sh "$url" "$destFolderAbsolute" "$pwd"
    if [ -n "$destFolder" ]; then 
      # only prune when destFolder is not null, otherwise we are deleting too much...
      $KC_HOME/pruneFolder.sh "$destFolderAbsolute"
    fi
  fi
done < $UserConfig

# generate covers
eval "$fbink \"Generating Covers\" " 
$covergen -g $DocumentRoot >/dev/null 2>&1
eval "$fbink \"KoboCloudSync finished\" " 
