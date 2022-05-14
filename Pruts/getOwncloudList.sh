#!/bin/sh

# Download the file-list of a specified share
# if the share is not password-protected, passwd is emtpy
#
# INPUT
# davServer: the dav-server address, eg. https://cloud.mycloud.com
# user: the username (shareID) of the file-share
# passwd: the password of the share eg: ojrsAQ2MYQjNRxy
#
# Output: the relative path of the files on the server.
# eg: /public.php/webdav/SharedFile.pdf

davServer="$1"
user="$2"
passwd="$3"


#load config
# . $(dirname $0)/config.sh
CURL=/usr/bin/curl


echo '<?xml version="1.0"?>
<a:propfind xmlns:a="DAV:">
<a:prop><a:resourcetype/></a:prop>
</a:propfind>' |
$CURL -k --silent -i -X PROPFIND -u $user:$passwd $davServer/public.php/webdav --upload-file - -H "Depth: infinity" | # get the listing
grep -Eo '<d:href>[^<]*[^/]</d:href>' | # get the links without the folders
sed 's@</*d:href>@@g'
