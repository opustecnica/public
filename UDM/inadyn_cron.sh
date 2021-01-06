#!/bin/sh
pgrep inadyn > null
if [ $? -eq 0 ]
then
    echo "inadyn is already running."
else
    /usr/sbin/inadyn -n -s -C -f /mnt/data/scripts/inadyn.conf &
    echo "starting inadyn."
fi
