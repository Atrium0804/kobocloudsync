#!/bin/sh

# https://raw.githubusercontent.com/Atrium0804/KoboNextcloudsync/main/src/usr/local/KoboCloudSync/getNextcloudFiles.sh

#function to percent-decode the filename from the OwnCloud URL
percentDecodeFileName() { printf "%b\n" "$(sed 's/+/ /g; s/%\([0-9a-f][0-9a-f]\)/\\x\1/g;')"; }

baseURL="$1"
outDir="$2"
pwd="$3"

#load config
. $(dirname $0)/config.sh


# webdav implementation
# https://myserver.com/s/shareLink
# or
# https://myserver.com/nextcloud/s/sharelink

# get the shareID
shareID=`echo $baseURL | sed -e 's@.*s/\([^/ ]*\)$@\1@'`
path="$(echo $baseURL | grep / | cut -d/ -f4-)"
davServerWithOwncloudPath=`echo $baseURL | sed -e 's@.*\(http.*\)/s/[^/ ]*$@\1@' -e 's@/index\.php@@'`
davServer=$(echo $1 | sed -e s,/$path,,g)

# check credentials
AuthMessage=$($KC_HOME/validateCredentials.sh "$shareID" "$pwd" "$davServerWithOwncloudPath")
if [ "$AuthMessage" ]; then
  echo "$RED Authentication Error: $AuthMessage"
  exit
fi

# Get Files for specified URL,
# > filter compatible extensions only
# > exclude Calibre's cover.jpg
$KC_HOME/getNextcloudFilelist.sh $davServerWithOwncloudPath $shareID $pwd | grep -i -f $ExtensionPatterns | grep -v '/cover.jpg' |
while read relativeLink
do
  # outFileName contains the relative path
  outFileNameRelative=`echo $relativeLink | sed 's/.*public.php\/webdav\///' | percentDecodeFileName`
  outFileName=$(echo $outFileNameRelative | awk -F '/' '{print $NF}')
  linkLine=$davServer$relativeLink
  localFile="$outDir/$outFileNameRelative"


  #  distinguish between
  #  .kepub.epub -> to be downloaded
  #  .epub -> to be downloaded and converted

  # convert filename to lowercase,  
  # if file is a epub, convert localFilename to .kepub.epub
  # mark for conversion
  oldIFS=$IFS
  IFS='%'

  localFile_lc=$(echo "$localFile" | tr '[:upper:]' '[:lower:]')
  pattern='tolower($0) ~ /^.*\.epub/ && ! /^.*\.kepub.epub/'  
  if [ $(echo $localFile_lc | awk "$pattern") ]; 
  then 
      tempfile=$localFile
      localFile=$(echo "$tempfile" | sed 's/\.epub$/\.kepub\.epub/i')
      isConvert=1
  else 
      # no conversion needed tempfile=localfile
      tempfile="$localFile"
      isConvert=0
  fi

  IFS=$oldIFS
  # Check if file is already downloaded
  if [ -f "$localFile" ]; then
      echo "   Existing: $outFileName"
     
  else
    # download the file
    echo "   Download: $outFileName"
    eval "$fbink \"Downloading: $outFileName\" "
    $KC_HOME/getRemoteFile.sh "$linkLine" "$tempfile" $shareID "-" "$pwd"
    if [ $? -ne 0 ] ; then
      echo "Having problems contacting Nextcloud. Try again in a couple of minutes."
      exit
    fi
    if [ "$isConvert" == "1" ]; then
    # convert epub to kepub
       echo "             Converting to kepub"
       eval "$fbink \"Converting to kepub: $outFileName\" "
       $kepubify "$tempfile"  -o "$localFile"  >/dev/null 2>&1
      #  echo "$localFile" >> "$RemoteFileList"
       rm -f "$tempfile"
    fi
  fi
  echo "$localFile" >> "$RemoteFileList"
done