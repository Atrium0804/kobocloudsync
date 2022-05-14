#!/bin/sh

# Doel:
# benodigde variabelen afleiden uit opgegeven pad.
# Stappen:
#  1 vaststellen: wat is de benodigde output?
#  2: werkt het voor eigen links en sharee-links

#load credentials
# . $(dirname $0)/test_credentials.sh

cyan='\033[0;36m'
NC='\033[0m'
KC_HOME=$(dirname $0)
CURL=/usr/bin/curl


# https://myserver.com/s/shareLink
# https://myserver.com/nextcloud/s/sharelink

# baseURL="https://cloud.famstieltjes.nl/nextcloud/remote.php/dav/files/clouduser/KoboSync"
# baseURL="https://cloud.famstieltjes.nl/remote.php/dav/files/clouduser/KoboSync"
# baseURL='https://cloud.famstieltjes.nl/s/9RADyQittBLc35y'
baseURL='https://cloud.famstieltjes.nl/nextcloud/s/9RADyQittBLc35y'

shareID=`echo $baseURL | sed -e 's@.*s/\([^/ ]*\)$@\1@'`

# get the protocol and domain only
path="$(echo $baseURL | grep / | cut -d/ -f4-)"
davServer=$(echo $baseURL | sed -e s,/$path,,g)

# Get the servername with path, used to get the file listing. (e.g. if the server uses domain.name/nextcloud, the nextcloud is kept as well.)
# verwijdert alleen /s/#######
davServerWithOwncloudPath=`echo $baseURL | sed -e 's@.*\(http.*\)/s/[^/ ]*$@\1@' -e 's@/index\.php@@'`
# Remove the path to get the protocol and main domain only (used with the relative paths which are a result of "getOwncloudList.sh".)
echo
echo "${cyan}Input:           ${NC} $baseURL"
echo "${cyan}davServerwithPath${NC} $davServerWithOwncloudPath"
echo "${cyan}davServer        ${NC} $davServer"
echo "${cyan}path             ${NC} $path"
echo "${cyan}shareID          ${NC} $shareID"


## davServerWithPath ##
	# -> get directorylisting
	# $KC_HOME/getOwncloudList.sh $shareID $davServerWithOwncloudPath
	# 
	# Voorbeelden
	# https://cloud.famstieltjes.nl/nextcloud/remote.php/dav/files/clouduser/KoboSync  -> zal wel niet kloppen
	# https://cloud.famstieltjes.nl/remote.php/dav/files/clouduser/KoboSync
	# https://cloud.famstieltjes.nl
	# https://cloud.famstieltjes.nl/nextcloud

$KC_HOME/getOwncloudList.sh $shareID $davServerWithOwncloudPath |
while read relativeLink
do
	echo "relativeLink $relativeLink"
  # process line 
#   outFileName=`echo $relativeLink | sed 's/.*public.php\/webdav\///' | percentDecodeFileName`
#   linkLine=$davServer$relativeLink
#   localFile="$outDir/$outFileName"
#   # get remote file
#   $KC_HOME/getRemoteFile.sh "$linkLine" "$localFile" $shareID
#   if [ $? -ne 0 ] ; then
#       echo "Having problems contacting Owncloud. Try again in a couple of minutes."
#       exit
#   fi
done