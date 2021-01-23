#!/bin/sh

MAC='20:c0:47:42:0a:bf'
IF=$(ip route show table 201 | awk '{print $5}')
ip link set dev $IF down
ip link set dev $IF address $MAC
ip link set dev $IF up
