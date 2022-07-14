#!/bin/sh

# Description:
#  This script donwloads files for a specified remote location
#  files will be downloaded when:
#   - the remote file does not exist locally
#   - the remote file has been changed (based on SHA1-hash)
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

remoteHashfilePath="$WorkDir/remotehashes.sha1"
$rclone sha1sum "$currentShare":/ --checkfile="$remoteHashfilePath" $rcloneOptions > /dev/null


# get all remote objects (files/folders)
# theJsonListing=`$rclone lsjson -R  $currentShare:/ $rcloneOptions`
theListing=`$rclone lsl $currentShare:/ $rcloneOptions`

# remove incompatible files
theListing=`echo "$theListing" | grep -i -f $ExtensionPatterns`
echo "$theListing" |
while IFS= read -r theLine; do
	echo 
	theTrimmedLine=`echo "$theLine" | awk '{ sub(/^[ \t]+/, ""); print }' ` 
	# theFilesize=`echo "$theTrimmedLine"  | cut -d ' ' -f 1`
	# theModTime=`echo "$theTrimmedLine"  | cut -d ' ' -f 2-3`
	theRelativePath=`echo "$theTrimmedLine"  | cut -d ' ' -f 4-`					# relative path of the file
	theFilename=`basename "$theRelativePath"`										# the (remote) filename

	theLocalFilepath="$DocumentRoot/$currentShare/$theRelativePath"
	theTargetFilepath=`echo "$theLocalFilepath" | sed "$kepubRenamePattern"`		# the filename with .epub renamed to .kepub.epub
	theDestinationFolder=$(dirname "$theTargetFilepath")
		
	echo "$CYAN `$Dt` $theRelativePath $NC"
	$rclone sha1sum "$currentShare":"$theRelativePath" --checkfile="$theTargetFilepath.sha1" $rcloneOptions > /dev/null
	hashcompare=$?

	if [ ! -f "$theTargetFilepath" ];	then 
		echo "   file does not exist"
	elif [ $hashcompare -eq 1 ]; then
		echo "   remote file change ($hashcompare)"
	fi
	
	# if the hashes are different or the target file does not exist: download the file
	if [ $hashcompare -eq 1 ] || [ ! -f "$theTargetFilepath" ];
		then
		# remove .sha1-file if exists, it might be corrupt
		if [ -f "$theTargetFilepath.sha1" ];
		then
			rm -f "$theTargetFilepath.sha1"
		fi
	
		inkscr "Download $theFilename"
		$rclone sync "$currentShare":"$theRelativePath" "$theDestinationFolder" $rcloneOptions

		# create hash-file	
		$rclone sha1sum "$currentShare":"$theRelativePath" --output-file="$theTargetFilepath.sha1" $rcloneOptions
		# convert to kepub if necessary and remove downloaded file
		if [ "$theFilename" != "$(basename "$theTargetFilepath")" ]; then 
			echo "convert to kepub"
			$kepubify "$theDestinationFolder/$theFilename"  -o "$theTargetFilepath" 
			rm -f "$theLocalFilepath"
		fi
	else
		echo "   no change"
	fi
done
