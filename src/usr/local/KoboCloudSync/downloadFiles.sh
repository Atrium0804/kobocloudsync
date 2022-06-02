#!/bin/sh

#load config
. $(dirname $0)/config.sh
  
echo "`$Dt` starting downloadFiles.sh"


shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
echo "$shares" |
while IFS= read -r currentShare; do
    echo "$YELLOW processing share: $currentShare $NC"    
    
	  # get all remote objects (files/folders)
    theJsonListing=`$rclone lsjson -R  $currentShare:/ $rcloneOptions`
    # get the list of remote files, remove quotes
    theRemoteFilepaths=`echo "$theJsonListing" | $jq  -c '.[] | select(.IsDir==false).Path' `
	theRemoteFilepaths=`echo "$theRemoteFilepaths" | sed "s/\"//g"`

	# Process the files in the current share
	echo "$theRemoteFilepaths" |
	while IFS= read -r theRemoteFile; do
		# calculated the tempfile and local filename
		# tempfile: remote filename with destination path
		# localfile: to kepub.epub converted filename with destination path
		theConvertedFilename=`echo "$theRemoteFile" | sed "$kepubRenamePattern"`
		te doen: filenaam van tempfolder afknippen
		theTempFolder=$DocumentRoot/$currentShare/$theRemoteFile
		theLocalFilepath=$DocumentRoot/$currentShare/$theConvertedFilename
		theHashFilepath=$DocumentRoot/$currentShare/$theConvertedFilename.sha1

	    echo " theRemoteFile:         $theRemoteFile $NC"
		echo "$CYAN theConvertedFilename:  $theConvertedFilename $NC"
		echo "$CYAN theTempFilepath:       $theTempFilepath $NC"
		echo "$CYAN theLocalFilepath:      $theLocalFilepath $NC"
		echo "$CYAN theHashFilepath:       $theHashFilepath $NC"

		# if the file is not compatible with the device, skip download
		# if the MD5-hash of the local file is differend from the remote file, the file should be downloaded
			# download the file
			# if successfull, download the MD5-hash to file
		# if the tempfilename is different from the local filename, convert epub to kepub-epub
		
		echo "validate local hash"
# echo		$rclone sha1sum "$currentShare":"$theRemoteFile" --checkfile="$theHashFilepath" $rcloneOptions
		$rclone sha1sum "$currentShare":"$theRemoteFile" --checkfile="$theHashFilepath" $rcloneOptions 
		if [ "$?"=="0" ]; then
			echo "file change detected"
			$rclone sync  "$currentShare":"$theRemoteFile" "$DocumentRoot/$currentShare/" $rcloneOptions

			echo "create hash file"
			$rclone sha1sum "$currentShare":"$theRemoteFile" --output-file="$theHashFilepath" $rcloneOptions
		fi


	
	
	done
	# echo "$CYAN check SHA-file$NC"
	# echo $rclone sha1sum "$currentShare":"$theRemoteFile" $rcloneOptions --checkfile "$theLocalFilepath.sha1 "
	# $rclone sha1sum "$currentShare":"$theRemoteFile" --checkfile "$theLocalFilepath.sha1 $rcloneOptions"
	# if [ './rclone sha1sum $theRemote:$theFile --checkfile $theSHAfile'==0 ]; then
	# 	echo "file change detected"
	# 	# download file

	# 	# download sha1-hash
	# 	echo "$CYAN create SHA-file $NC"
	#     # $Rclone sha1sum $theRemote:$theFile --output-file "$theLocalFilepath.sha1"
	# fi

done

