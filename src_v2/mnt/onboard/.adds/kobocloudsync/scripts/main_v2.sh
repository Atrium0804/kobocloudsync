#!/bin/sh

# script for downloading epubs to a kobo device from a remote location
# using rclone for file transfer and kepubify for converting epubs to kepub-epubs
# requires rclone and kepubify to be installed

printf "\nStarting KoboCloudSync download script\n"
Dt="date +%Y-%m-%d_%H:%M:%S"
verbose=true

# load configuration
scripts_folder=$(dirname $0)
. $scripts_folder/config.sh

# check start conditions
. $scripts_folder/checkStartConditions.sh


#################################################################
# fetch list of remote shares from rclone config file
#################################################################
echo ""
echo "Fetching remote shares from rclone config file..."
shares=`$rclone listremotes --config="$rclone_config_file" | sed 's/://' `
if [ -z $shares ];
then
    echo " ERROR: No shares in configfile $rclone_config_file"
    exit 1
fi
echo "Found the following shares:"
echo "$shares" | sed 's/^/  - /'
echo ""

# process each share: list files and download metadata
shareCount=$(echo "$shares" | wc -l)
shareNum=0
echo "$shares" |
while IFS= read -r currentShare; do
    shareNum=$((shareNum + 1))
    echo ""
    echo "[$shareNum/$shareCount] Processing share: $currentShare"

    filename_metadata_remote="$installation_folder/${currentShare}_metadata_remote.txt"
    filename_metadata_local="$installation_folder/${currentShare}_metadata_local.txt"

    # download remote metadata
    echo ""
    echo "Fetching remote metadata for $currentShare..."
    $rclone lsl "$currentShare":/ --config="$rclone_config_file" > $filename_metadata_remote

    if [ $? -ne 0 ]; then
        echo "  [ERROR] Failed to fetch remote metadata for $currentShare"
        exit 1
    else
        # remove incompatible/unwanted files from remote file listing
        theRemoteFileListing=`cat "$filename_metadata_remote" | grep -i -f $scripts_folder/extensionPatterns.txt`
    fi
    # echo "  [OK] Remote metadata retrieved for $currentShare"
    theLocalFileListing=`cat "$filename_metadata_local" `

#################################################
# update local metadata file: remove entries for files that no longer exist remotely
#################################################
# if a user deleted a local file manually on the kobo device, the local metadata file
# may contain entries for files that no longer exist remotely.
# In this case, we need to remove these entries from the local metadata file
echo "---"
echo "Processing local metadata cleanup for $currentShare..."
    # for each line in the local file listing: determine the file name and path
    # the filename is the 4th field onwards
    echo "$theLocalFileListing" |
    while IFS= read -r theLocalLine; do
        # Remove leading whitespace
        theTrimmedLine=`echo "$theLocalLine" | awk '{sub(/^[ \t]+/, ""); print}'`
        theRelativePath=`echo "$theTrimmedLine" | cut -d ' ' -f 4-`
        theFilename=`basename "$theRelativePath"`
        # epubs are converted to kepub.epub, calculate kepub filename from epub filename
        theLocalFilepath="$document_folder/$currentShare/$theRelativePath"
        theKepubFilepath=`echo "$theLocalFilepath" | sed 's/\.epub$/.kepub.epub/i'`
        theMetadataFile="${theKepubFilepath}.metadata"


        # if the local line does not exist in the remote file listing, remove it from local metadata
        if echo "$theRemoteFileListing" | grep -q "$theLocalLine"
        then
            # remote/local metadata is identical, keep the line
            :
        else
            # metadata changed or file deleted remotely:
            # remove theLine from filename_metadata_local
            sed -i.bak "/$theRelativePath/d" "$filename_metadata_local"
            echo "  [UPDATE] Removed local metadata for missing file: $theRelativePath"
        fi
    done

#################################################
# process deletions: delete files that are changed or deleted remotely
#################################################
echo "Processing deletes for ..."
    # for each line in the local file listing: determine the file name and path
    # the filename is the 4th field onwards
    echo "$theLocalFileListing" |
    while IFS= read -r theLocalLine; do
        # Remove leading whitespace
        theTrimmedLine=`echo "$theLocalLine" | awk '{sub(/^[ \t]+/, ""); print}'`
        theRelativePath=`echo "$theTrimmedLine" | cut -d ' ' -f 4-`
        theFilename=`basename "$theRelativePath"`

        # if the local line does not exist in the remote file listing, delete the local file and metadata
        if echo "$theRemoteFileListing" | grep -q "$theLocalLine"
        then
            # remote/local metadata is identical, keep the file
            echo "  [SKIP] File unchanged (metadata match) $theFilename"
        else
            # metadata changed or file deleted remotely:
            # delete the local file
            # remove theLine from filename_metadata_local
            theLocalFilepath="$document_folder/$currentShare/$theRelativePath"
            theKepubFilepath=`echo "$theLocalFilepath" | sed 's/\.epub$/.kepub.epub/i'`
            theMetadataFile="${theKepubFilepath}.metadata"

            # delete the original epub file if it exists
            if [ -f "$theLocalFilepath" ]; then
                echo "  [DELETE] Local file: $theLocalFilepath"
                rm -f "$theLocalFilepath"
            fi

            # delete the converted kepub file if it exists
            if [ -f "$theKepubFilepath" ]; then
                echo "  [DELETE] Converted kepub file: $theKepubFilepath"
                rm -f "$theKepubFilepath"
            fi

            # delete the metadata file if it exists
            if [ -f "$theMetadataFile" ]; then
                echo "  [DELETE] Metadata file: $theMetadataFile"
                rm -f "$theMetadataFile"
            fi

            # remove the line from the local metadata file
            sed -i.bak "/$theRelativePath/d" "$filename_metadata_local"
            echo "  [UPDATE] Removed local metadata for deleted file: $theRelativePath"
        fi
    done

#################################################
# process downloads/updates: check for remote files that are new or changed
#################################################
# for each line in the remote file listing: check if the line exists in the local metadata
# download the file when no line is found
echo "---"
echo "Processing downloads/updates for $currentShare..."
    echo "$theRemoteFileListing" |
    while IFS= read -r theRemoteLine; do
        # Remove leading whitespace
        theTrimmedLine=`echo "$theRemoteLine" | awk '{sub(/^[ \t]+/, ""); print}'`
        theRelativePath=`echo "$theTrimmedLine" | cut -d ' ' -f 4-`
        theFilename=`basename "$theRelativePath"`

        # if the remote line does not exist in the local file listing, download the file
        if echo "$theLocalFileListing" | grep -q "$theRemoteLine"
        then
            # remote/local metadata is identical, no download
            echo "  [SKIP] File unchanged (metadata match) $theRelativePath"
            doDownload=0
        else
            # remote/local hashes are different or file is new, download file
            echo "  [DOWNLOAD] New or updated file detected: $theRelativePath"
            theLocalFilepath="$document_folder/$currentShare/$theRelativePath"
            theDestinationFolder=$(dirname "$theLocalFilepath")
            mkdir -p "$theDestinationFolder"
            $rclone copy "$currentShare:/$theRelativePath" "$theDestinationFolder" --config="$rclone_config_file"
            if [ $? -ne 0 ]; then
                echo "    [ERROR] Failed to download file: $theRelativePath"
            else
                echo "    [OK] File downloaded: $theLocalFilepath"
                # update local metadata file
                grep -v "$theRelativePath" "$filename_metadata_local" > "${filename_metadata_local}.tmp"
                mv "${filename_metadata_local}.tmp" "$filename_metadata_local"
                echo "$theRemoteLine" >> "$filename_metadata_local"
                echo "    [OK] Local metadata updated"
            fi
        fi
    done
done
echo ""
