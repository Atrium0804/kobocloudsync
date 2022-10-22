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
remoteMetadataListing="$WorkDir/remote_metadata.txt" 
$rclone lsl "$currentShare":/ $rcloneOptions  > $remoteMetadataListing

# get all remote objects (files/folders) and remove incompatible files
theRemoteFileListing=`$rclone lsl $currentShare:/ $rcloneOptions`
theRemoteFileListing=`echo "$theRemoteFileListing" | grep -i -f $ExtensionPatterns`

# process remote files
echo "$theRemoteFileListing" |
while IFS= read -r theLine; do
	theTrimmedLine=`echo "$theLine" | awk '{ sub(/^[ \t]+/, ""); print }' ` 
	# theFilesize=`echo "$theTrimmedLine"  | cut -d ' ' -f 1`
	# theModTime=`echo "$theTrimmedLine"  | cut -d ' ' -f 2-3`
	theRelativePath=`echo "$theTrimmedLine"  | cut -d ' ' -f 4-`					# relative path of the file
	theFilename=`basename "$theRelativePath"`										# the (remote) filename
	echo "$GREEN === $theRelativePath === $NC"

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
			doDownload=0
		else
			# remote/local hashes are different, redownload file
			echo "remote file different to local file"
			doDownload=1
		fi
	else
	#	echo "no local metadata stored"
		doDownload=1
	fi

	# if the hashes are different or the target file does not exist: download the file
	if [ $doDownload -eq 1 ] || [ ! -f "$theTargetFilepath" ];
		inkscr "Downloading $theFilename"
		rm -f "$theLocalMetadata"
		$rclone sync "$currentShare":"$theRelativePath" "$theDestinationFolder" $rcloneOptions
		if [ $? -eq 0 ];
		then
			# download successfull, store the  metadata of the current file in separate file
			grep "$theRelativePath" "$remoteMetadataListing" > $theLocalMetadata
			# store triggerfile for triggering the processing of  downloads later on
			touch "$booksdownloadedTrigger"
		else 
			echo "$RED ERROR Downloading file" 
		fi

		# convert to kepub if necessary and remove downloaded file
		if [ "$theFilename" != "$(basename "$theTargetFilepath")" ]; then 
			echo "Converting to kepub"
			$kepubify "$theDestinationFolder/$theFilename"  -o "$theTargetFilepath" > /dev/null
			rm -f "$theLocalFilepath"
		fi
	else
		echo "   no change"
	fi
done