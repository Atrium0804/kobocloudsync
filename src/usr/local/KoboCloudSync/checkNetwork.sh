#!/bin/sh


# checks for a working network-connection by pinging aws.amazon.com
# exit codes:
#  0 - network connection available
#  1 - no network connection found

#load config
. $(dirname $0)/config.sh

# set device specific wait-parameter
case $device in
"kobo") waitparm='-w' 
        timeout=30
    ;;
     *) waitparm='-i'
        timeout=2
     ;;
esac

inkscr "$CYAN waiting for internet connection $NC"
r=1;i=0
while [ $r != 0 ]; do
    if [ $i -gt $timeout ]; then
        inkscr "$RED error! no connection detected $NC" 
        exit 1
    fi
    echo "$CYAN `$Dt` Pinging $NC"    
    ping -c 1 $waitparm 3 aws.amazon.com >/dev/null 2>&1
    r=$? # get the exit-status of the previous cmd, 0=successful
    if [ $r != 0 ]; then sleep 1; fi
    i=$(($i + 1))
done
echo "$CYAN `$Dt` internet connection found $NC"
