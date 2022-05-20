#!/bin/sh
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
# Extract the path.
path="$(echo $baseURL | grep / | cut -d/ -f4-)"
# Get the servername with path, used to get the file listing. (e.g. if the server uses domain.name/nextcloud, the nextcloud is kept as well.)
davServerWithOwncloudPath=`echo $baseURL | sed -e 's@.*\(http.*\)/s/[^/ ]*$@\1@' -e 's@/index\.php@@'`
# Remove the path to get the protocol and main domain only (used with the relative paths which are a result of "getOwncloudList.sh".)
davServer=$(echo $1 | sed -e s,/$path,,g)

# echo "shareID:                   $shareID"
# echo "davServer:                 $davServer"
# echo "davServerWithOwncloudPath: $davServerWithOwncloudPath"

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
  # process line 
  outFileName=`echo $relativeLink | sed 's/.*public.php\/webdav\///' | percentDecodeFileName`
  linkLine=$davServer$relativeLink
  localFile="$outDir/$outFileName"

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
      echo "epub, to be converted"
      tempfile=$localFile
      localFile=$(echo "$tempfile" | sed 's/\.epub$/\.kepub\.epub/i')
      isConvert=1
  else 
      # no conversion needed tempfile=localfile
      echo "kepub.epub or no epub, no conversion"
      tempfile=$localFile
      isConvert=0
  fi
  IFS=$oldIFS
  # Check if file is already downloaded
  if [ -f "$localFile" ]; then
      echo "  Existing file, skipping: $outFileName"
      # append to local filelist
      echo "$localFile" >> "$RemoteFileList"
      # exit 0
  else
    # download the file
    echo "new file, downloading $outFileName"
    $KC_HOME/getRemoteFile.sh "$linkLine" "$tempfile" $shareID "-" "$pwd"
    if [ $? -ne 0 ] ; then
      echo "Having problems contacting Owncloud. Try again in a couple of minutes."
      exit
    fi
    if [ isConvert==1 ]; then
    # convert epub to kepub
       echo "Converting to kepub: $filename"
       $kepubify "$tempfile"  -o "$localFile" 
       echo "$localFile" >> "$RemoteFileList"
      rm -f "$tempfile"
    fi

  fi
done