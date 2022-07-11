# #!/bin/sh

# prune the local files: removed files which are deleted or moved on the remote location
# - get a list of remote files
# - convert to local filenames
# - convert local files not on the remote list
#
# Possible improvements:
# - remove code duplication with downloadFiles.sh
# - add: delete empty folders
#
# duplicate code from downloadFiles.sh
# we first want to create the file list and then start downloading the files
# this in case of a network connection drop. so we are sure we aren't deleting
# which are on the server but couldn't be processed due to network outage.
#
# Better would be some error handling ;)

#load config
. $(dirname $0)/config.sh
  
# prevent file list from being deleted
echo "$RemoteFileList" > $RemoteFileList


# define function 
pruneFolder(){
	echo "Pruning folder $1"
	find "$1" -type f |
	while IFS= read -r item; do
	  	if grep -Fq "$item" "$RemoteFileList"; 
			then 
				exec # do nothing
				#  echo "$CYAN [Keep] $item $NC"
			else 
				echo "   [rm] $item"
				rm -f "$item"
		fi
	done 
 	# remove empty directories
	# we don't do it recursively,
	find "$1" -type d |
	while IFS= read -r theFolder; do
		if !   ls -1A "$theFolder" | grep -q . 
			then 
				echo "[rmdir] $theFolder/"
				rmdir "$theFolder" --ignore-fail-on-non-empty
			else
				exec
				# echo "$CYAN [keep] $theFolder/ $NC"
		fi
	done
}


# create a list with remote files
# #proces shares
shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
echo "$shares" | 
while IFS= read -r currentShare; do
    echo "$YELLOW pruning share: $currentShare $NC"    
    destinationFolder=$DocumentRoot/$currentShare
	theRemoteFiles=`$rclone lsf -R $currentShare:/ $rcloneOptions | grep -v '.*\/$' `	# keep files only
	echo "$theRemoteFiles" | 
    while IFS= read -r theRemoteFile; do
        # same code as in downloadFiles.sh
		# echo "$CYAN [remote file] $theRemoteFile $NC"
        theTargetFilename=`echo "$theRemoteFile" | sed "$kepubRenamePattern"`			# rename to kepub.epub
        theLocalFilepath="$destinationFolder/$theTargetFilename"						# create absolute path
        echo "$theLocalFilepath" >> $RemoteFileList										# add to file to list
        echo "$theLocalFilepath.sha1" >> $RemoteFileList								# add hashfile to list
    done

	pruneFolder "$destinationFolder"
done