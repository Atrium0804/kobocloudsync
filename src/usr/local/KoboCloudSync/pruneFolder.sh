#!/bin/sh

# Pruning folder:
# - prune files which are not found on the server (files not in the filelist)
# - prune empty directories

theFolderToPrune=$1

#load config
. $(dirname $0)/config.sh

pruneFolder(){
	# find all files in the local folder 
	# and delete when not on the Remote file list.
	find "$1" -type f |
	while IFS= read -r item; do
	  	if grep -Fq "$item" "$RemoteFileList"; 
			then 
				exec # do nothing
				echo "Keep:    $item"
			else 
				echo "${CYAN}Pruning: $item $NC"
				rm -f "$item"
		fi
	done 
 	# find and remove empty directorie
 	find "$1"  -type d |
	while IFS= read -r item; do
		rmdir --parents --ignore-fail-on-non-empty "$item"
	done
}
pruneFolder "$theFolderToPrune"