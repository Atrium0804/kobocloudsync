#!/bin/sh

# Doel:
# benodigde variabelen afleiden uit opgegeven pad.
# Stappen:
#  1 vaststellen: wat is de benodigde output?
#  2: werkt het voor eigen links en sharee-links

#load credentials
. $(dirname $0)/test_credentials.sh

cyan='\033[0;36m'
NC='\033[0m'

# https://myserver.com/s/shareLink
# https://myserver.com/nextcloud/s/sharelink

# baseURL="https://cloud.famstieltjes.nl/nextcloud/remote.php/dav/files/clouduser/KoboSync"
# baseURL="https://cloud.famstieltjes.nl/remote.php/dav/files/clouduser/KoboSync"
# baseURL='https://cloud.famstieltjes.nl/s/9RADyQittBLc35y'
baseURL='https://myserver.com/nextcloud/s/sharelink'

# Extract the path.
path="$(echo $baseURL | grep / | cut -d/ -f4-)"
# Get the servername with path, used to get the file listing. (e.g. if the server uses domain.name/nextcloud, the nextcloud is kept as well.)
# verwijdert alleen /s/#######
davServerWithOwncloudPath=`echo $baseURL | sed -e 's@.*\(http.*\)/s/[^/ ]*$@\1@' -e 's@/index\.php@@'`
# Remove the path to get the protocol and main domain only (used with the relative paths which are a result of "getOwncloudList.sh".)
davServer=$(echo $baseURL | sed -e s,/$path,,g)

echo "${cyan}Input:           ${NC} $baseURL"
echo "${cyan}davServerwithPath${NC} $davServerWithOwncloudPath"
echo  "${cyan}path            ${NC} $path"
echo  "${cyan}davServer       ${NC} $davServer"

#load conf
# . $(dirname $0)/config.sh

# echo '<?xml version="1.0"?>
# <a:propfind xmlns:a="DAV:">
# <a:prop><a:resourcetype/></a:prop>
# </a:propfind>' |
# $CURL -k --silent -i -X PROPFIND -u $user: $davServer/public.php/webdav --upload-file - -H "Depth: infinity" | # get the listing
# $CURL -k --silent -i -X PROPFIND -u $user: $davServer/public.php/webdav --upload-file - -H "Depth: infinity" | # get the listing
# grep -Eo '<d:href>[^<]*[^/]</d:href>' | # get the links without the folders
# sed 's@</*d:href>@@g'
