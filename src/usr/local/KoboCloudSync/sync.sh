#!/bin/sh

#load config
. $(dirname $0)/config.sh

# testing 

#  get remote shares
shares=`grep -E '^\[.*\]$' $rcloneConfig | sed 's/[][]//g'`
rm $rcloneLogfile
echo "`$Dt` start" >> $rcloneLogfile

# process the remote shares
echo "$shares" |
while IFS= read -r currentShare; do
    destination=$DocumentRoot/$currentShare

    ## on device conversion
    # get file list
    # write filelist epub ->kepub.epub
    # for each file
    #  compare MD5 checksums local vs remote
    #    download and convert
    # delete files not on file list 

    echo
    echo "$YELLOW share: $currentShare ... $NC"    
    echo "dest:  $destination"
    $rclone lsf -R  $currentShare:/ $rcloneOptions
    $rclone sync    $currentShare:/ $destination $rcloneOptions
done

# rclone sync   - Make source and dest identical, modifying destination only.
# rclone ls     - List all the objects in the path with size and path.
# rclone rmdirs - Remove any empty directories under the path.

# ./rclone ls test:/ --config=rclone.config 
# ./rclone sync  test:/ ./data --config=rclone.config 