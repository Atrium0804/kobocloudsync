#!/bin/sh


# checks for a working network-connection by pinging aws.amazon.com
# exit codes:
#  0 - network connection available
#  1 - no network connection found

# #load config
# . $(dirname $0)/config.sh

# set device specific wait-parameter
case $device in
"kobo") waitparm='-w'
        timeout=30
        pingcmd="ping -c 1 $waitparm 3"
    ;;
     *) if uname -a | grep -q 'W64_NT'; then
            # Windows ping syntax
            timeout=2
            pingcmd="ping -n 1 -w 3000"
        else
            # Mac/Linux ping syntax
            waitparm='-i'
            timeout=2
            pingcmd="ping -c 1 $waitparm 3"
        fi
     ;;
esac

r=1;i=0
while [ $r != 0 ]; do
    if [ $i -gt $timeout ]; then
        inkscr "error! no connection detected"
        exit 1
    fi
    # echo "Pinging"
    $pingcmd aws.amazon.com >/dev/null 2>&1
    r=$? # get the exit-status of the previous cmd, 0=successful
    if [ $r != 0 ]; then sleep 1; fi
    i=$(($i + 1))
    # inkscr "waiting for internet connection"
done
echo "internet connection found"
