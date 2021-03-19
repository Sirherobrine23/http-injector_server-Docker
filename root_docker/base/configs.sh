#!/bin/bash
echo "acl all src 0.0.0.0/0 ::/0

# Allow
http_access allow all

# Deny
# http_access deny all

#Ports
http_port 80
http_port 8080
http_port 554
http_port 1935
http_port 7070
http_port 8000
http_port 8001

# Options
visible_hostname Docker
via off
forwarded_for off
pipeline_prefetch off" > /etc/squid/squid.conf

# All service status
{
    service dropbear start 
    service ssh start
    service squid start
    service pptpd start
    
} &> /tmp/service_status
/scripts/badvpn.sh
netstat -alpn |grep 'pptp'
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && iptables-save
iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
iptables -I INPUT -s 10.0.0.0/8 -i ppp0 -j ACCEPT
iptables --append FORWARD --in-interface eth0 -j ACCEPT