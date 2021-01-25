#!/bin/sh

APP_PID="/run/suricata.pid"

cat <<"EOF" > /tmp/suricata.sh
#!/bin/sh
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

# Add wg0 interface
grep -q 'wg0' /run/ips/config/iface.yaml
if [ $? -ne 0 ]; then
  # sed -i -E "s/(.*)(br0)$/\1wg0/" /run/ips/config/iface.yaml
  echo "   - interface: wg0" >> /run/ips/config/iface.yaml 
  #
fi

/tmp/suricata.backup "$@"
EOF

chmod +x /tmp/suricata.sh
cp /usr/bin/suricata /tmp/suricata.backup # In case you want to move back without rebooting
ln -f -s /tmp/suricata.sh /usr/bin/suricata

if [ ! -z "$APP_PID" ]; then
  killall -9 suricata
  rm -f APP_PID
fi
