#load config
. $(dirname $0)/config.sh

configfile=/private/tmp/KoboCloudSync/KoboCloudSync.conf
echo "#######################################"
while read line || [ -n "$line" ]; do
#   echo "Reading $line"
  if echo "$line" | grep -q '^#'; then
     exec # comment found, do nothing
  elif echo "$line" | grep -q "^REMOVE_DELETED$"; then
	exec
  else
	echo "dataline: $line"
	a=$(echo "$line" | cut -d, -f1)
	b=$(echo "$line" | cut -d, -f2)
	c=$(echo "$line" | cut -d, -f3-)
	echo "dest=$a"
	echo "URL=$b"
	echo "pwd=$c"
fi
done <$configfile



# IFS=',' #setting comma as delimiter  
# while read line || [ -n "$line" ]; do
# #   echo "Reading $line"
#   if echo "$line" | grep -q '^#'; then
#    exec # comment found, do nothing
#   elif echo "$line" | grep -q "^REMOVE_DELETED$"; then
# 	  echo "Files deleted on the server will be removed from this device."
#   else
#     # split the line in DestinationFolder, URL and password
#     echo "${YELLOW}Reading $line${NC}"
#     read -a strarr <<<"$line"
#     destFolder=${strarr[0]} # relative path
#     url=${strarr[1]}  
#     pwd=${strarr[2]}
#     # strip leading/trailing spaces
#     pwd="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'<<<"${pwd}")"
#     # echo "$GREEN -${pwd}-"
#     destFolderAbsolute="$DocumentRoot/$destFolder"

#     $KC_HOME/getNextcloudFiles.sh "$url" "$destFolderAbsolute" "$pwd"
#   fi
# done < $UserConfig
