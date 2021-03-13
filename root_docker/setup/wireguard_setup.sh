#!/bin/bash
# Run setup questions first
echo "Welcome to the WireGuard installer!"
echo "The git repository is available at: https://github.com/angristan/wireguard-install"
echo ""
echo "I need to ask you a few questions before starting the setup."
echo "You can leave the default options and just press enter if you are ok with them."
echo ""

# Detect public IPv4 or IPv6 address and pre-fill for the user
SERVER_PUB_IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
if [[ -z ${SERVER_PUB_IP} ]]; then
	# Detect public IPv6 address
	SERVER_PUB_IP=$(ip -6 addr | sed -ne 's|^.* inet6 \([^/]*\)/.* scope global.*$|\1|p' | head -1)
fi
# SERVER_PUB_IP="${SERVER_PUB_IP}"
SERVER_PUB_IP=`wget -qO- https://ipecho.net/plain`

# Detect public interface and pre-fill for the user
SERVER_NIC="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
SERVER_PUB_NIC="${SERVER_NIC}"

SERVER_WG_NIC="wg0"

SERVER_WG_IPV4="10.66.66.1"

SERVER_WG_IPV6="fd42:42:42::1"

# Generate random number within private ports range
SERVER_PORT='51820'

# Adguard DNS by default
CLIENT_DNS_1="8.8.8.8"
CLIENT_DNS_2="1.1.1.1"
echo ""
echo "Okay, that was all I needed. We are ready to setup your WireGuard server now."
##installQuestions
# Make sure the directory exists (this does not seem the be the case on fedora)
mkdir /etc/wireguard >/dev/null 2>&1
chmod 600 -R /etc/wireguard/
SERVER_PRIV_KEY=$(wg genkey)
SERVER_PUB_KEY=$(echo "${SERVER_PRIV_KEY}" | wg pubkey)
# Save WireGuard settings
echo "SERVER_PUB_IP=${SERVER_PUB_IP}
SERVER_PUB_NIC=${SERVER_PUB_NIC}
SERVER_WG_NIC=${SERVER_WG_NIC}
SERVER_WG_IPV4=${SERVER_WG_IPV4}
SERVER_WG_IPV6=${SERVER_WG_IPV6}
SERVER_PORT=${SERVER_PORT}
SERVER_PRIV_KEY=${SERVER_PRIV_KEY}
SERVER_PUB_KEY=${SERVER_PUB_KEY}
CLIENT_DNS_1=${CLIENT_DNS_1}
CLIENT_DNS_2=${CLIENT_DNS_2}" >/etc/wireguard/params
# Add server interface
echo "[Interface]
Address = ${SERVER_WG_IPV4}/24,${SERVER_WG_IPV6}/64
ListenPort = ${SERVER_PORT}
PrivateKey = ${SERVER_PRIV_KEY}" >"/etc/wireguard/${SERVER_WG_NIC}.conf"
if pgrep firewalld; then
    FIREWALLD_IPV4_ADDRESS=$(echo "${SERVER_WG_IPV4}" | cut -d"." -f1-3)".0"
    FIREWALLD_IPV6_ADDRESS=$(echo "${SERVER_WG_IPV6}" | sed 's/:[^:]*$/:0/')
    echo "PostUp = firewall-cmd --add-port ${SERVER_PORT}/udp && firewall-cmd --add-rich-rule='rule family=ipv4 source address=${FIREWALLD_IPV4_ADDRESS}/24 masquerade' && firewall-cmd --add-rich-rule='rule family=ipv6 source address=${FIREWALLD_IPV6_ADDRESS}/24 masquerade'
PostDown = firewall-cmd --remove-port ${SERVER_PORT}/udp && firewall-cmd --remove-rich-rule='rule family=ipv4 source address=${FIREWALLD_IPV4_ADDRESS}/24 masquerade' && firewall-cmd --remove-rich-rule='rule family=ipv6 source address=${FIREWALLD_IPV6_ADDRESS}/24 masquerade'" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"
else
    echo "PostUp = iptables -A FORWARD -i ${SERVER_PUB_NIC} -o ${SERVER_WG_NIC} -j ACCEPT; iptables -A FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; iptables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE; ip6tables -A FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; ip6tables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE
PostDown = iptables -D FORWARD -i ${SERVER_PUB_NIC} -o ${SERVER_WG_NIC} -j ACCEPT; iptables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; iptables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE; ip6tables -D FORWARD -i ${SERVER_WG_NIC} -j ACCEPT; ip6tables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"
fi
# Enable routing on the server
echo "net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >/etc/sysctl.d/wg.conf
sysctl --system
# Start Wireguard
echo "Wireguard start Tunnel ${SERVER_WG_NIC}"
ip link add dev ${SERVER_WG_NIC} type wireguard
ip address add dev ${SERVER_WG_NIC} ${SERVER_WG_IPV4}/24
ip link set up dev ${SERVER_WG_NIC}
printf 'nameserver %s\n' '8.8.8.8' | resolvconf -a tun.${SERVER_WG_NIC} -m 0 -x

sysctl -w net.ipv4.conf.all.rp_filter=2

wg-quick up ${SERVER_WG_NIC}