#!/bin/sh

# Description
# Syncs remote shares as defined in the rclone.conf file to a local destination
# Deletes local files removed from server
# Creates covers for downloaded books.
#
# uses:
# kepubify: https://github.com/pgaskin/kepubify
# jq:       https://github.com/stedolan/jq
# rclone:   https://github.com/rclone/rclone

#load config
. $(dirname $0)/config.sh

echo
echo "$YELLOW ======================================================"
echo "`$Dt` start - version  2025-12-20T2037"
echo ""
echo "Configuration:"
echo "  WorkDir:      $WorkDir"
echo "  KoboFolder:   $KoboFolder"
echo "  DocumentRoot: $DocumentRoot"
echo "======================================================$NC"

# clear the rclone logfile
echo "`$Dt`" > "$rcloneLogfile"

# validate rclone configuration
echo "$YELLOW--- Validating rclone configuration ---$NC"
echo "  Config file: $rcloneConfig"
if [ -f "$rcloneConfig" ]; then
    echo "  [OK] Config file exists"
    # Check for URLs without protocol scheme (http:// or https://)
    invalidUrls=$(grep -E "^url = [^h]" "$rcloneConfig" | grep -v "^url = http")
    if [ ! -z "$invalidUrls" ]; then
        echo "$RED ERROR: Invalid URL format in rclone.conf"
        echo "URLs must start with http:// or https://"
        echo "Found invalid entries:"
        echo "$invalidUrls"
        inkscr "Config error: URLs need http:// or https://"
        exit 1
    fi
    echo "  [OK] URL formats valid"
else
    echo "$RED ERROR: rclone.conf not found at $rcloneConfig"
    inkscr "Config file not found"
    exit 1
fi

# check working network connection
echo ""
echo "$YELLOW--- Checking network connection ---$NC"
$SH_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ];
then
    echo "$RED[ERROR] No network connection, aborting$NC"
    exit 1
fi
echo "$GREEN[OK] Network connection verified$NC"

#  get remote shares and download files
echo ""
echo "$YELLOW--- Discovering remote shares ---$NC"
shares=`$rclone listremotes $rcloneOptions | sed 's/://' `
if [ -z $shares ];
then
    echo "$RED[ERROR] No shares in configfile $rcloneConfig$NC"
    exit 1
fi

shareCount=$(echo "$shares" | wc -l)
echo "$GREEN[OK] Found $shareCount share(s):$NC"
echo "$shares" | sed 's/^/  - /'
echo ""

# download remote files for each share
echo "$YELLOW--- Processing shares ---$NC"
shareNum=0
echo "$shares" |
while IFS= read -r currentShare; do
    shareNum=$((shareNum + 1))
    echo ""
    echo "$YELLOW[$shareNum/$shareCount] Processing share: $currentShare$NC"
    $HOME/opt/downloadFiles.sh "$currentShare"
    echo "$GREEN[$shareNum/$shareCount] Completed share: $currentShare$NC"
done

# check network again as the kobo might close the wifi after a while
echo ""
echo "$YELLOW--- Pruning deleted files ---$NC"
echo "  Verifying network connection..."
$SH_HOME/checkNetwork.sh
hasNetwork=$?
if [ $hasNetwork -ne 0 ];
then
    echo "$RED[ERROR] No network connection, aborting pruning$NC"
    exit 1
fi
echo "  [OK] Network active"
$SH_HOME/pruneFolders.sh

echo ""
echo "$YELLOW--- Post-processing ---$NC"
if [ -f $booksdownloadedTrigger ]; then
    echo "  New books detected, generating covers and metadata..."
    echo "  Running covergen..."
    $covergen "$KoboFolder" > /dev/null
    echo "  Running seriesmeta..."
    $seriesmeta "$KoboFolder" > /dev/null
    rm -f $booksdownloadedTrigger
    echo "$GREEN[OK] Post-processing complete$NC"
    inkscr "cloudsync: rescan your e-books."
else
    echo "  No new books downloaded"
    echo "$GREEN[OK] kobocloudsync ready, no new e-books$NC"
fi

echo ""
echo "$GREEN======================================================"
echo "`$Dt` kobocloudsync completed successfully"
echo "======================================================$NC"