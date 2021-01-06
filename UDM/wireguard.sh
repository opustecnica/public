#!/bin/sh
CONTAINER=wireguard
# Starts a wireguard container that is deleted after it is stopped.
# All configs stored in /mnt/data/wireguard
if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  podman run -it --restart always -d --net=host --name ${CONTAINER} --privileged \
    -v /mnt/data/wireguard:/etc/wireguard \
    -v /dev/net/tun:/dev/net/tun \
    -e LOG_LEVEL=info -e WG_COLOR_MODE=always \
    masipcat/wireguard-go
fi

