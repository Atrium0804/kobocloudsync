# #!/bin/sh

# # prune the local files: removed files which are deleted or moved on the remote location
# # - get a list of remote files
# # - convert to local filenames
# # - convert local files not on the remote list
# #
# # Possible improvements:
# # - remove code duplication with downloadFiles.sh
# # - add: delete empty folders
# #
# # duplicate code from downloadFiles.sh
# # we first want to create the file list and then start downloading the files
# # this in case of a network connection drop. so we are sure we aren't deleting
# # which are on the server but couldn't be processed due to network outage.
# #
# # Better would be some error handling ;)

#load config
. $(dirname $0)/config.sh
  
# prevent file list from being deleted
echo "$RemoteFileList" > $RemoteFileList


# define function 
pruneFolder(){
	# find all files in the local folder 
	# and delete when not on the Remote file list.
	echo "Pruning folder $1"
	find "$1" -type f |
	while IFS= read -r item; do
	  	if grep -Fq "$item" "$RemoteFileList"; 
			then 
				exec # do nothing
				# echo "Pruning: Keep:    $item"
			else 
				echo "removing: $item"
				# rm -f "$item"
		fi
	done 
 	# todo: find and remove empty directories
}

# #proces shares
shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
echo "$shares" |
while IFS= read -r currentShare; do
    echo "$YELLOW processing share: $currentShare $NC"    
    destination=$DocumentRoot/$currentShare
   
    # get all remote objects (files/folders)
    theJsonListing=`$rclone lsjson -R  $currentShare:/ $rcloneOptions`
    theRemoteFilepaths=`echo "$theJsonListing" | $jq  -c '.[] | select(.IsDir==false).Path' `
	theRemoteFilepaths=`echo "$theRemoteFilepaths" | sed "s/\"//g"`
    
    echo "$theRemoteFilepaths" |
    while IFS= read -r theRemoteFile; do
        # same code as in downloadFiles.sh
        theConvertedFilename=`echo "$theRemoteFile" | sed "$kepubRenamePattern"`
        theLocalFilepath=$DocumentRoot/$currentShare/$theConvertedFilename
        theHashFilepath=$DocumentRoot/$currentShare/$theConvertedFilename.sha1
        echo "$theLocalFilepath" >> $RemoteFileList
        echo "$theHashFilepath" >> $RemoteFileList
    done

	pruneFolder "$destination"
done