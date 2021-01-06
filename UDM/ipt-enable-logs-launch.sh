#!/bin/sh

# Copy the file to a location usable by the unifi-os container.
SCRIPT=/mnt/data/unifi-os/ipt-enable-logs.sh
if test -f "$SCRIPT"
  then
    echo -e "SCRIPT exists at destination."
  else
    echo -e "SCRIPT doesn't exists at destination."
    cp /mnt/data/scripts/ipt-enable-logs.sh $SCRIPT
fi

podman exec -it unifi-os /bin/bash /data/ipt-enable-logs.sh && iptables-restore -c < /mnt/data/unifi-os/ipt-save

