#!/bin/sh

# Description:
#  This script donwloads files for a specified remote location
#  files will be downloaded when:
#   - the remote file does not exist locally
#   - the remote file has been changed (based on filesize and timestamp)
#   - the file is compatible with the kobo e-reader
#
#  Upon downloading a .epub-file, it will be converted to a .kepub.epub file.
#
# Usage: downloadFiles.sh sharename
# where sharename as defined in the rclone.conf file
#
# as we are converting epubs to kepubs, we can't use the rclone sync command, as it would download all epubs every time

#load config
. $(dirname $0)/config.sh
currentShare=$1

echo "`$Dt` starting downloadFiles.sh for share '$currentShare'"

# get remote metdata and store in file
echo "  Fetching remote metadata..."
remoteMetadataListing="$WorkDir/remote_metadata"
$rclone lsl "$currentShare":/ $rcloneOptions  > $remoteMetadataListing
if [ $? -ne 0 ]; then
    echo "$RED  [ERROR] Failed to fetch remote metadata$NC"
    exit 1
fi
echo "  [OK] Remote metadata retrieved"

# get all remote objects (files/folders) and remove incompatible files
theRemoteFileListing=`$rclone lsl $currentShare:/ $rcloneOptions`
theRemoteFileListing=`echo "$theRemoteFileListing" | grep -i -f $ExtensionPatterns`

# Print remote file list
fileCount=$(echo "$theRemoteFileListing" | grep -c .)
echo "$YELLOW--- Remote files found for '$currentShare': $fileCount file(s) ---$NC"
if [ -z "$theRemoteFileListing" ]; then
	echo "  (no compatible files found)"
else
	echo "$theRemoteFileListing" | sed 's/^/  /'
fi
echo "$YELLOW--- Processing files ---$NC"

# process remote files
fileNum=0
echo "$theRemoteFileListing" |
while IFS= read -r theLine; do
	fileNum=$((fileNum + 1))
	theTrimmedLine=`echo "$theLine" | awk '{ sub(/^[ \t]+/, ""); print }' `
	# theFilesize=`echo "$theTrimmedLine"  | cut -d ' ' -f 1`
	# theModTime=`echo "$theTrimmedLine"  | cut -d ' ' -f 2-3`
	theRelativePath=`echo "$theTrimmedLine"  | cut -d ' ' -f 4-`					# relative path of the file
	theFilename=`basename "$theRelativePath"`									# the (remote) filename
	echo ""
	echo "$GREEN[$fileNum/$fileCount] === $theRelativePath ===$NC"

	# calculate target filename (.kepub.epub)
	theLocalFilepath="$DocumentRoot/$currentShare/$theRelativePath"
	theTargetFilepath=`echo "$theLocalFilepath" | sed "$kepubRenamePattern"`		# the filename with .epub renamed to .kepub.epub
	theDestinationFolder=$(dirname "$theTargetFilepath")
	theLocalMetadata="$theTargetFilepath.metadata"

	# retrieve the (remote) metadata for the file
	theRemoteMetadataLine=`grep "$theRelativePath" "$remoteMetadataListing"`

	# Download file if the metadata has changed
	if [ -f "$theLocalMetadata" ]; then
		if grep -q "$theRemoteMetadataLine" "$theLocalMetadata"
		then
			# remote/local metadata is identical, no download
			echo "  [SKIP] File unchanged (metadata match)"
			doDownload=0
		else
			# remote/local hashes are different, redownload file
			echo "  [UPDATE] Remote file different from local"
			echo "    Remote: $theRemoteMetadataLine"
			echo "    Local:  $(cat "$theLocalMetadata")"
			doDownload=1
		fi
	else
		echo "  [NEW] No local copy found"
		doDownload=1
	fi

	# if the hashes are different or the target file does not exist: download the file
	if [ $doDownload -eq 1 ] || [ ! -f "$theTargetFilepath" ];
	then
		echo "  [DOWNLOAD] Starting download..."
		inkscr "Downloading $theFilename"
		# Create destination folder if it doesn't exist
		mkdir -p "$theDestinationFolder"
		echo "    Destination: $theDestinationFolder"
		rm -f "$theLocalMetadata"
		$rclone sync "$currentShare":"$theRelativePath" "$theDestinationFolder" $rcloneOptions
		if [ $? -eq 0 ];
		then
			echo "  $GREEN[OK] Download successful$NC"
			# download successfull, store the  metadata of the current file in separate file
			grep "$theRelativePath" "$remoteMetadataListing" > $theLocalMetadata
			# store triggerfile for triggering the processing of  downloads later on
			touch "$booksdownloadedTrigger"
		else
			echo "  $RED[ERROR] Download failed$NC"
		fi

		# convert to kepub if necessary and remove downloaded file
		if [ "$theFilename" != "$(basename "$theTargetFilepath")" ]; then
			echo "  [CONVERT] Converting to kepub format..."
			$kepubify "$theDestinationFolder/$theFilename"  -o "$theTargetFilepath" > /dev/null
			if [ $? -eq 0 ]; then
				echo "  $GREEN[OK] Conversion successful$NC"
				# Remove original epub file after conversion
				echo "  [CLEANUP] Removing original epub..."
				rm -f "$theDestinationFolder/$theFilename"
			else
				echo "  $RED[ERROR] Conversion failed$NC"
			fi
		fi
	fi
done

# delete remote file listing
rm "$WorkDir/remote_metadata"