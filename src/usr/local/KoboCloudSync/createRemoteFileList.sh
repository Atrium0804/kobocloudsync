#!/bin/sh

# create a list with remote files in order to determine
# which local files have been deleted from the remote server
#
# as we perform an on-device conversion or .epub-files to .kepub.epub files
# we have to store remote epub-filenames as .kepub.epub


#load config
. $(dirname $0)/config.sh

kepubRenamePattern='/.kepub.epub"$/! s/\.epub"$/\.kepub\.epub"/i'  
  
echo "`$Dt` starting createRemoteFileList.sh"
echo "`$Dt` writing to $RemoteFileList"

# get the share-names
shares=`$rclone listremotes $rcloneOptions | sed 's/://' `

# prevent file list from being deleted
echo "$RemoteFileList" > $RemoteFileList

# download file list from shares
# rename to kepub.epub when required
echo "$shares" |
while IFS= read -r currentShare; do
    destination=$DocumentRoot/$currentShare
    echo "$YELLOW processing share: $currentShare $NC"    
    # get all remote objects (files/folders)
    theJsonListing=`$rclone lsjson -R  $currentShare:/ $rcloneOptions`
    # filter files only
    theFilepaths=`echo "$theJsonListing" | $jq  -c '.[] | select(.IsDir==false).Path' `
	theFilepaths=`echo "$theFilepaths" | sed "$kepubRenamePattern"`
	#insert destination 
	theFilepaths=`echo "$theFilepaths" | sed "s;\";\"$DocumentRoot/$currentShare/;"`
	echo "$theFilepaths" >>$RemoteFileList
done

