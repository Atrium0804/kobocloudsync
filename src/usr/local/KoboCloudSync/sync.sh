#!/bin/sh

#load config
. $(dirname $0)/config.sh


echo "`$Dt` start" 

# test if the an internet-connection is available
# by pinging aws.amazon.com
    case $device in
    "kobo") waitparm='-w' ;;
         *) waitparm='-i' ;;
    esac
    if [ "$TEST" = "" ]
    then
        echo "$CYAN `$Dt` waiting for internet connection $NC"
        eval "$fbink \"waiting for internet connection\" "
        r=1;i=0
        while [ $r != 0 ]; do
        if [ $i -gt 60 ]; then
            ping -c 1 $waitparm 3 aws.amazon.com >/dev/null 2>&1
            echo "`$Dt` error! no connection detected" 
            "$fbink  \"error! no connection detected\" " 
            exit 1
        fi
        ping -c 1 $waitparm 3 aws.amazon.com >/dev/null 2>&1
        r=$? # get the exit-status of the previous cmd, 0=successful
        if [ $r != 0 ]; then sleep 1; fi
        i=$(($i + 1))
        done
    fi

#  get remote shares
echo "$CYAN get shares $NC"
shares=`$rclone listremotes $rcloneOptions | sed 's/://' `


# rclone sync   - Make source and dest identical, modifying destination only.
# rclone ls     - List all the objects in the path with size and path.
# rclone rmdirs - Remove any empty directories under the path.

# ./rclone ls test:/ --config=rclone.config 
# ./rclone sync  test:/ ./data --config=rclone.config 