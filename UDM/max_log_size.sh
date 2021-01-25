#!/bin/sh
# Set a limit for container logs. 104857600 Bytes = 100 Megabytes
sed -i 's/max_log_size = -1/max_log_size = 104857600/g' /etc/containers/libpod.conf;
