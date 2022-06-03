#!/bin/sh

#load config
. $(dirname $0)/config.sh
  
echo "`$Dt` starting downloadFiles.sh"

shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
echo "$shares" |
while IFS= read -r currentShare; do
    echo "$GREEN processing share: $currentShare $NC"    
    
	  # get all remote objects (files/folders)
    theJsonListing=`$rclone lsjson -R  $currentShare:/ $rcloneOptions`
    # get the list of remote files, remove quotes
    theRemoteFilepaths=`echo "$theJsonListing" | $jq  -c '.[] | select(.IsDir==false).Path' `
	theRemoteFilepaths=`echo "$theRemoteFilepaths" | sed "s/\"//g"`

	# Process the files in the current share
	echo "$theRemoteFilepaths" |
	while IFS= read -r theRemoteFile; do
		theFilename=`basename "$theRemoteFile"`									# the original filename without path
		theTargetFilename=`echo "$theFilename" | sed "$kepubRenamePattern"`		# the target filename with .epub renamed to .kepub.epub
		theLocalFolder=`dirname "$DocumentRoot/$currentShare/$theRemoteFile"`	# the destination folder (including remote subfolders)

		theHashfile="$theLocalFolder/$theTargetFilename.sha1"
	    echo "$ORANGE theRemoteFilePath:  $theRemoteFile $NC"
		echo "$CYAN theFilename:       $theFilename $NC"
		echo "$CYAN theTargetFilename: $theTargetFilename $NC"
		echo "$CYAN theHashfile:       $theHashfile $NC"
		# echo "$CYAN theHashFilepath:       $theHashFilepath $NC"

		# if the file is not compatible with the device, skip download
		# if the MD5-hash of the local file is differend from the remote file, the file should be downloaded
			# download the file
			# if successfull, download the MD5-hash to file
		# if the tempfilename is different from the local filename, convert epub to kepub-epub
		
		echo "validate local hash"
# echo		$rclone sha1sum "$currentShare":"$theRemoteFile" --checkfile="$theHashFilepath" $rcloneOptions
		$rclone sha1sum "$currentShare":"$theRemoteFile" --checkfile="$theHashfile" $rcloneOptions 
		hashcompare=$?
		# if the hash is different or the local file is missing, download the file
		if [ $hashcompare -eq 1 ] || [ ! -f "$theLocalFolder/$theTargetFilename" ];
		 then
			echo "$ORANGE downloading file and hash $NC"
			$rclone sync  "$currentShare":"$theRemoteFile" "$theLocalFolder/" $rcloneOptions
			$rclone sha1sum "$currentShare":"$theRemoteFile" --output-file="$theHashfile" $rcloneOptions
			echo "$theHashfile" >> "$RemoteFileList"
		
			if [ "$theFilename" != "$theTargetFilename" ]; then 
				echo "$orange converting to kepub $NC"
				inkscr "Converting to kepub: $theFilename"
       			$kepubify "$theLocalFolder/$theFilename"  -o "$theLocalFolder/$theTargetFilename"  >/dev/null 2>&1
				rm -f "$theLocalFolder/$theFilename"
			fi
		else
			echo $CYAN "no file change $NC"
		fi
	done
done

