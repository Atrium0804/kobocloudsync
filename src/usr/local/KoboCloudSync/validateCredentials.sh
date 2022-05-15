#!/bin/sh

# checks on authentication errors

# <s:message>[^<]*[^/]<[/]s:message>
#load config
. $(dirname $0)/config.sh

username=$1
password=$2
URL=$3

output=$( echo '<?xml version="1.0"?>
		<a:propfind xmlns:a="DAV:">
		<a:prop><a:resourcetype/></a:prop>
		</a:propfind>' |
		$CURL -k --silent -i -X PROPFIND -u $username:$password $URL/public.php/webdav --upload-file - -H "Depth: infinity"  )
# output=$( $CURL -k --silent -i -u $username:$password $URL)
echo "$output"  |  grep -silent -Eo '<s:exception>[^<]*[^/]<[/]s:exception>'
if  [ $?!=0 ] ; then 
	echo "$output" | grep -Eo '<s:message>[^<]*[^/]<[/]s:message>' | sed 's@</*s:message>@@g' 
fi
