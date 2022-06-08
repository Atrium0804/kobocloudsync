#!/bin/sh


# checks for a working network-connection
# exit codes:
#  0 - network connection available
#  1 - no network connection found

#load config
. $(dirname $0)/config.sh

# test if the an internet-connection is available
# by pinging aws.amazon.com
case $device in
"kobo") waitparm='-w' 
        timeout=30
    ;;
     *) waitparm='-i'
        timeout=2
     ;;
esac

echo "$CYAN `$Dt` waiting for internet connection $NC"
r=1;i=0
while [ $r != 0 ]; do
    if [ $i -gt $timeout ]; then
        echo "$RED `$Dt` error! no connection detected $NC" 
        exit 1
    fi
    echo "$CYAN `$Dt` Pinging $NC"    
    ping -c 1 $waitparm 3 aws.amazon.com >/dev/null 2>&1
    r=$? # get the exit-status of the previous cmd, 0=successful
    if [ $r != 0 ]; then sleep 1; fi
    i=$(($i + 1))
done
echo "$CYAN `$Dt` internet connection found $NC"
