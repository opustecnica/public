#!/bin/sh

cat > /run/dnsmasq.conf.d/custom_dns.conf <<- "EOF"
# Created by a UDM-Utilities run script
# Change the domains and IP address to your own
interface=wg0
EOF

# Restart dnsmasq so it sees the new conf file
pkill dnsmasq
