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

inkscr "Getting Remote"



#rclone make list of files need to sync

diffFile=$DocumentRoot/difffile.log

$rclone check $currentShare:eBooks/ $DocumentRoot $rcloneOptions --combined $diffFile  --exclude $diffFile

#read the diff file and download the files
# if difffile line starts with = or ! skip, otherwise download

# sed away line including difffile.log
sed -i '/difffile.log/d' $diffFile



#count the number of lines in the diff file
theDiffFileLineCount=`wc -l $diffFile | awk '{print $1}'`
#count the number of lines in the diff file starting with = or !
# theDiffFileSkipCount=`grep -c -e "^=" -e "^!" $diffFile`
theDiffFileSkipCount=`grep -c -e "^=" $diffFile`

theDiffFileDownloadCount=$((theDiffFileLineCount-theDiffFileSkipCount))
echo "theDiffFileLineCount: $theDiffFileLineCount"
echo "theDiffFileSkipCount: $theDiffFileSkipCount"
echo "theDiffFileDownloadCount: $theDiffFileDownloadCount"

echo "Downloading $theDiffFileDownloadCount : $theDiffFileLineCount  files"
inkscr "Downloading $theDiffFileDownloadCount : $theDiffFileLineCount  files"
sleep 2

counter=0
while IFS= read -r line
do
	#get first character
	# echo "line: $line"
	#if line is - difffile
	filename=`echo $line | cut -c3-`
	tidystring=`echo $line | sed 's/.*\///'`
	pathname=`echo $filename | sed 's/\/[^\/]*$//'`




	firstChar=`echo $line | cut -c1-1`
	if [ "$firstChar" = "=" ] ; then
		echo "skip $tidystring"
	elif [ "$firstChar" = "-" ]; then
		echo "delete $tidystring"
		#delete the file
		$rclone delete "$currentShare:eBooks/$filename" "$DocumentRoot/$pathname" $rcloneOptions
		touch "$booksdownloadedTrigger"

	else
		echo "download $tidystring"
		counter=$((counter+1))
		progressstring=`echo $counter:$theDiffFileDownloadCount $tidystring`

		inkscr "$progressstring"
		#download the file
		$rclone copy "$currentShare:eBooks/$filename" "$DocumentRoot/$pathname" $rcloneOptions
		touch "$booksdownloadedTrigger"

	fi

done < $diffFile



	


# # get remote metdata and store in file
# remoteMetadataListing="$WorkDir/remote_metadata.txt" 
# $rclone lsl $currentShare:eBooks/ $rcloneOptions  > $remoteMetadataListing

# # get all remote objects (files/folders) and remove incompatible files
# theRemoteFileListing=`$rclone lsl $currentShare:eBooks/ $rcloneOptions`
# theRemoteFileListing=`echo "$theRemoteFileListing" | grep -i -f $ExtensionPatterns`

# # process remote files
# echo "$theRemoteFileListing" |
# while IFS= read -r theLine; do
# 	theTrimmedLine=`echo "$theLine" | awk '{ sub(/^[ \t]+/, ""); print }' ` 
# 	# theFilesize=`echo "$theTrimmedLine"  | cut -d ' ' -f 1`
# 	# theModTime=`echo "$theTrimmedLine"  | cut -d ' ' -f 2-3`
# 	theRelativePath=`echo "$theTrimmedLine"  | cut -d ' ' -f 4-`					# relative path of the file
# 	theFilename=`basename "$theRelativePath"`										# the (remote) filename
# 	echo "$GREEN === $theRelativePath === $NC"

# 	# calculate target filename (.kepub.epub)
# 	theLocalFilepath="$DocumentRoot/$currentShare/$theRelativePath"
# 	theTargetFilepath=`echo "$theLocalFilepath" | sed "$kepubRenamePattern"`		# the filename with .epub renamed to .kepub.epub
# 	theDestinationFolder=$(dirname "$theTargetFilepath")
# 	theLocalMetadata="$theTargetFilepath.metadata"

# 	# retrieve the (remote) metadata for the file 
# 	theRemoteMetadataLine=`grep "$theRelativePath" "$remoteMetadataListing"`

# 	# Download file if the metadata has changed
# 	if [ -f "$theLocalMetadata" ]; then
# 		if grep -q "$theRemoteMetadataLine" "$theLocalMetadata"
# 		then
# 			# remote/local metadata is identical, no download
# 			doDownload=0
# 		else
# 			# remote/local hashes are different, redownload file
# 			echo "remote file different to local file"
# 			echo "remote metadata: $theRemoteMetadataLine"
# 			echo "local  metadata: $theLocalMetadata"
# 			doDownload=1
# 		fi
# 	else
# 	#	echo "no local metadata stored"
# 		doDownload=1
# 	fi

# 	# if the hashes are different or the target file does not exist: download the file
# 	if [ $doDownload -eq 1 ] || [ ! -f "$theTargetFilepath" ];
# 	then
# 		inkscr "Downloading $theFilename"
# 		rm -f "$theLocalMetadata"
# 		$rclone sync "$currentShare":eBooks/"$theRelativePath" "$theDestinationFolder" $rcloneOptions
# 		if [ $? -eq 0 ];
# 		then
# 			# download successfull, store the  metadata of the current file in separate file
# 			grep "$theRelativePath" "$remoteMetadataListing" > $theLocalMetadata
# 			# store triggerfile for triggering the processing of  downloads later on
# 			touch "$booksdownloadedTrigger"
# 		else 
# 			echo "$RED ERROR Downloading file" 
# 		fi

# 		# # convert to kepub if necessary and remove downloaded file
# 		# if [ "$theFilename" != "$(basename "$theTargetFilepath")" ]; then 
# 		# 	echo "Converting to kepub"
# 		# 	$kepubify "$theDestinationFolder/$theFilename"  -o "$theTargetFilepath" > /dev/null
# 		# 	rm -f "$theLocalFilepath"
# 		# fi
# 	else
# 		echo "   no change"
# 	fi
# done