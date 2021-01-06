#!/bin/sh

echo "Creating on boot script on device"
echo '#!/bin/sh

EXECUTE01="/mnt/data/scripts/ipt-enable-logs-launch.sh"
FILE="/mnt/data/udapi-config/ubios-udapi-server/ubios-udapi-server.state"
### daemonized section ######
LAST=`ls -l "$FILE"`
while true; do
    sleep 1
    NEW=`ls -l "$FILE"`
    if [ "$NEW" != "$LAST" ]; then
    DATE=`date`
    # echo "${DATE}: Executing ${EXECUTE01}"
    $EXECUTE01
    LAST="$NEW"
    fi
done
#### end of daemonized section ####

' > /mnt/data/scripts/udmwatchdog.sh

chmod u+x /mnt/data/scripts/udmwatchdog.sh

echo "Creating script to modify unifios container"
echo '#!/bin/sh

echo "#!/bin/sh
ssh -o StrictHostKeyChecking=no root@127.0.1.1 ''/mnt/data/scripts/udmwatchdog.sh''" > /etc/init.d/udm-watch.sh
chmod u+x /etc/init.d/udm-watch.sh

echo "[Unit]
Description=Run On UDM Watchdog at Startup 
After=network.target

[Service]
ExecStart=/etc/init.d/udm-watch.sh

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/udmwatchdog.service

systemctl enable udmwatchdog
systemctl start udmwatchdog
' > /tmp/install-watchdog-unifios.sh

podman cp /tmp/install-watchdog-unifios.sh unifi-os:/root/install-watchdog-unifios.sh
podman exec -it unifi-os chmod +x /root/install-watchdog-unifios.sh
echo "Executing container modifications"
podman exec -it unifi-os sh -c /root/install-watchdog-unifios.sh
rm /tmp/install-watchdog-unifios.sh

echo "Installed the UDM watchdog."