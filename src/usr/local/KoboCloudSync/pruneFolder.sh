#!/bin/sh

# Pruning folder:
# - prune files which are not found on the server (files not in the filelist)
# - prune empty directories

theFolderToPrune=$1

#load config
. $(dirname $0)/config.sh

function pruneFolder(){
	# find all files in the local folder 
	# and delete when not on the Remote file list.
	find "$1" -type f -print0 |
	while IFS= read -r -d '' item; do
	  	if grep -Fq "$item" "$RemoteFileList"; 
			then 
				exec # do nothing
			else 
				echo "Pruning $item"
				rm -f "$item"
		fi
	done 
	# find and remove empty directorie
	find "$1" -empty -type d -delete
}
pruneFolder "$theFolderToPrune"