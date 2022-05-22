#!/bin/sh

# Download the file-list of a specified webdav-share
# if the share is not password-protected, passwd is emtpy
#
# INPUT
# davServer: the dav-server address, eg. https://cloud.mycloud.com
# user: the username (shareID) of the file-share
# passwd: the password of the share eg: ojrsAQ2MYQjNRxy
#
# Output: the relative path of the files on the server.
# a recursive list of files is reported
# eg: 
# /public.php/webdav/SharedFile.pdf
# /public.php/webdav/SubFolder/SharedFile2.pdf
#
# Limitations:
# - works on shared folders only, not on shared files.


# name the arguments
davServer="$1"
user="$2"
pwd="$3"

#load config
. $(dirname $0)/config.sh

# get the XML with files and extract the filepaths
echo '<?xml version="1.0"?>
<a:propfind xmlns:a="DAV:">
<a:prop><a:resourcetype/></a:prop>
</a:propfind>' |
$CURL --insecure --silent --include --request PROPFIND --user $user:$pwd $davServer/public.php/webdav --upload-file - --header "Depth: infinity" | 
grep -Eo '<d:href>[^<]*[^/]</d:href>' | 
sed 's@</*d:href>@@g'