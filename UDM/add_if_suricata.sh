#!/bin/sh

# USAGE: add_if_suricata.sh wg0

CUSTOM_RULES="/mnt/data/suricata-rules"
for file in $(find ${CUSTOM_RULES} -name '*.rules' -print)
do
    if [ -f "${file}" ]; then
        bname=$(basename ${file})
        cp "${file}" "/run/ips/rules/${bname}"
        # Check if the existing filename is already in the rules.yaml based upon a previous update
        grep -wq "${bname}" /run/ips/config/rules.yaml
        # Don't add twice if it is in the file already
        if [ $? -ne 0 ]; then
            echo " - ${bname}" >> /run/ips/config/rules.yaml
        fi
    fi
done

# Add $1 interface
grep -q $1 /run/ips/config/iface.yaml
if [ $? -ne 0 ]; then
  # sed -i -E "s/(.*)(br0)$/\1$1/" /run/ips/config/iface.yaml
  echo "   - interface: $1" >> /run/ips/config/iface.yaml
  #
fi

# Restart
APP_PID="/run/suricata.pid"
if [ ! -z "$APP_PID" ]; then
  killall -9 suricata
  rm -f APP_PID
fi
