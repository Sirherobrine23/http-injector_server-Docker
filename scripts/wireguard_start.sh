#!/bin/bash
source /etc/wireguard/params
echo "Wireguard start Tunnel ${SERVER_WG_NIC}"
ip link add dev ${SERVER_WG_NIC} type wireguard

ip link set up dev ${SERVER_WG_NIC}
printf 'nameserver %s\n' '8.8.8.8' | resolvconf -a tun.${SERVER_WG_NIC} -m 0 -x

sysctl -w net.ipv4.conf.all.rp_filter=2
