#!/bin/sh

# downloads a remote file using the curl-command
# Arguments
# linkLine    - the URL for the file to download
# localFile   - the absolute local filename for the file to be saved
# user        - username to authenticate with (ShareID for Nextcloud public shares)
# dropboxPath -
# pwd         - password to authenticate with

#load config
. $(dirname $0)/config.sh


# retry=true expet when NORETRY is passed to the script as an argument
retry="TRUE"
if [ "$1" = "NORETRY" ]
then
    retry="FALSE"
    shift 1
fi

# name the arguments
linkLine="$1"
localFile="$2"
user="$3"
dropboxPath="$4"
pwd="$5"
outputFileTmp="$WorkDir/kobo-remote-file-tmp.log"

# add the epub extension to kepub files
if echo "$localFile" | grep -Eq '\.kepub$'
then
    localFile="$localFile.epub"
fi

#load config
. $(dirname $0)/config.sh

# compose curl-command - add username/password if specified
curlCommand="$CURL"
if [ ! -z "$user" ] && [ "$user" != "-" ]; then
   curlCommand="$curlCommand -u $user:$pwd "
fi

# for dropbox: add dropbox-header
if [ ! -z "$dropboxPath" ] && [ "$dropboxPath" != "-" ]; then
    curlCommand="$CURL -X POST --header \"Authorization: Bearer $user\" --header \"Dropbox-API-Arg: {\\\"path\\\": \\\"$dropboxPath\\\"}\""
fi

# Download the file:
#  compose, execute command and evaluate exitcode 
#  writing the output to file
eval $curlCommand -k --silent -C - -L --create-dirs -o \"$localFile\" \"$linkLine\" -v 2>$outputFileTmp
status=$?

statusCode=`grep 'HTTP/' "$outputFileTmp" | tail -n 1 | cut -d' ' -f3`
grep -q "Cannot resume" "$outputFileTmp"
errorResume=$?
rm $outputFileTmp

case $statusCode in
    "200") exec
        #    echo "Status:OK"
           ;;
    "401") echo "${RED}Error: Unauthorized${NC}" 
            # exit 2 
            ;;
    "403") echo "${RED}Error: Forbidden${NC}"
            # exit 2 
            ;;
    "416") echo "${RED}Error: Range not satisfiable (file exist?)${NC}" 
            # exit 2 
            ;;
    *)
        echo "statuscode: $statusCode"
        if echo "$statusCode" | grep -q "50.*"; then
        echo "${RED}Error: Server error, statuscode $statusCode ${NC}"
        if [ $errorResume ] && [ "$retry" = "TRUE" ]
        then
            echo "Can't resume. Checking size"
            contentLength=$(eval $curlCommand -k -sLI "$linkLine" | grep -i 'Content-Length' | sed 's/.*:\s*\([0-9]*\).*/\1/')
            existingLength=`stat --printf="%s" "$localFile"`
            echo "Remote length: $contentLength"
            echo "Local length: $existingLength"
            if [ $contentLength = 0 ] || [ $existingLength = $contentLength ]
            then
                echo "Not redownloading - Size not available or file already downloaded"
            else
                echo "Retrying download"
                rm "$localFile"
                $0 NORETRY "$@"
            fi
        else
            echo "exit 3"
            exit 3
        fi
    fi
    ;;
esac;