#!/bin/sh

#load config
. $(dirname $0)/config.sh
  
echo "`$Dt` starting downloadFiles.sh"


shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
echo "$shares" |
while IFS= read -r currentShare; do
    echo "$YELLOW processing share: $currentShare $NC"    
    
	destination=$DocumentRoot/$currentShare
    # get all remote objects (files/folders)
    theJsonListing=`$rclone lsjson -R  $currentShare:/ $rcloneOptions`
    # get the list of remote files
    theRemoteFilepaths=`echo "$theJsonListing" | $jq  -c '.[] | select(.IsDir==false).Path' `

	echo "$theRemoteFilepaths" |
	while IFS= read -r theRemoteFile; do
		# calculated the tempfile and local filename
		# tempfile: remote filename with destination path
		# localfile: to kepub.epub converted filename with destination path
		theConvertedFilename=`echo "$theRemoteFile" | sed "$kepubRenamePattern"`
		theTempFilepath=`echo "$theRemoteFile" | sed "s;\";\"$DocumentRoot/$currentShare/;"`
		theLocalFilepath=`echo "$theConvertedFilename" | sed "s;\";\"$DocumentRoot/$currentShare/;"`
		theLocalMD5path=`echo "$theConvertedFilename" | sed "s;\";\"$DocumentRoot/$currentShare/;"`

		# if the file is not compatible with the device, skip download
		# if the MD5-hash of the local file is differend from the remote file, the file should be downloaded
			# download the file
			# if successfull, download the MD5-hash to file
		# if the tempfilename is different from the local filename, convert epub to kepub-epub
		echo
		echo "remote: $theRemoteFile"
		echo "temp:   $theTempFilepath"
		echo "local:  $theLocalFilepath"
		theHash=`$rclone sha1sum  $currentShare:"test2.kepub.epub" $rcloneOptions`
		echo "theHash: $theHash"
		theHash=`$rclone sha1sum  $currentShare:$theRemoteFile $rcloneOptions`
		echo "theHash: $theHash"
		# echo "hash: $rclone sha1sum $currentShare:$theRemoteFile $rcloneOptions`"
	done

	#insert destination 
	echo "$theFilepaths" >>$RemoteFileList
done

