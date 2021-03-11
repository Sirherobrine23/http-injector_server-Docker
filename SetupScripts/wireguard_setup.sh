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
systemctl start "wg-quick@${SERVER_WG_NIC}"
# systemctl enable "wg-quick@${SERVER_WG_NIC}"
# Check if WireGuard is running
systemctl is-active --quiet "wg-quick@${SERVER_WG_NIC}"
WG_RUNNING=$?
# WireGuard might not work if we updated the kernel. Tell the user to reboot
if [[ ${WG_RUNNING} -ne 0 ]]; then
    echo -e "\nWARNING: WireGuard does not seem to be running."
    echo "You can check if WireGuard is running with: systemctl status wg-quick@${SERVER_WG_NIC}"
    echo "If you get something like \"Cannot find device ${SERVER_WG_NIC}\", please reboot!"
fi
echo "If you want to add more clients, you simply need to run this script another time!"

#!/bin/bash
CLIENT_NAME="User01"

ENDPOINT="${SERVER_PUB_IP}:${SERVER_PORT}"
echo ""
echo "Tell me a name for the client."
echo "The name must consist of alphanumeric character. It may also include an underscore or a dash and can't exceed 15 chars."
until [[ ${CLIENT_NAME} =~ ^[a-zA-Z0-9_-]+$ && ${CLIENT_EXISTS} == '0' && ${#CLIENT_NAME} -lt 16 ]]; do
	# read -rp "Client name: " -e CLIENT_NAME
	echo "Client name: ${CLIENT_NAME}"
	CLIENT_EXISTS=$(grep -c -E "^### Client ${CLIENT_NAME}\$" "/etc/wireguard/${SERVER_WG_NIC}.conf")
	if [[ ${CLIENT_EXISTS} == '1' ]]; then
		echo ""
		echo "A client with the specified name was already created, please choose another name."
		echo ""
	fi
done
for DOT_IP in {2..254}; do
	DOT_EXISTS=$(grep -c "${SERVER_WG_IPV4::-1}${DOT_IP}" "/etc/wireguard/${SERVER_WG_NIC}.conf")
	if [[ ${DOT_EXISTS} == '0' ]]; then
		break
	fi
done
if [[ ${DOT_EXISTS} == '1' ]]; then
	echo ""
	echo "The subnet configured supports only 253 clients."
	exit 1
fi
until [[ ${IPV4_EXISTS} == '0' ]]; do
	# read -rp "Client's WireGuard IPv4: ${SERVER_WG_IPV4::-1}" -e -i "${DOT_IP}" DOT_IP
	echo "${CLIENT_NAME} IPv4: ${DOT_IP}"
	CLIENT_WG_IPV4="${SERVER_WG_IPV4::-1}${DOT_IP}"
	IPV4_EXISTS=$(grep -c "$CLIENT_WG_IPV4" "/etc/wireguard/${SERVER_WG_NIC}.conf")
	if [[ ${IPV4_EXISTS} == '1' ]]; then
		echo ""
		echo "A client with the specified IPv4 was already created, please choose another IPv4."
		echo ""
	fi
done
until [[ ${IPV6_EXISTS} == '0' ]]; do
	# read -rp "Client's WireGuard IPv6: ${SERVER_WG_IPV6::-1}" -e -i "${DOT_IP}" DOT_IP
	echo "${CLIENT_NAME} IPv6: ${DOT_IP}"
	CLIENT_WG_IPV6="${SERVER_WG_IPV6::-1}${DOT_IP}"
	IPV6_EXISTS=$(grep -c "${CLIENT_WG_IPV6}" "/etc/wireguard/${SERVER_WG_NIC}.conf")
	if [[ ${IPV6_EXISTS} == '1' ]]; then
		echo ""
		echo "A client with the specified IPv6 was already created, please choose another IPv6."
		echo ""
	fi
done
# Generate key pair for the client
CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "${CLIENT_PRIV_KEY}" | wg pubkey)
CLIENT_PRE_SHARED_KEY=$(wg genpsk)
# Home directory of the user, where the client configuration will be written
if [ -e "/home/${CLIENT_NAME}" ]; then # if $1 is a user name
	HOME_DIR="/home/${CLIENT_NAME}"
elif [ "${SUDO_USER}" ]; then # if not, use SUDO_USER
	HOME_DIR="/home/${SUDO_USER}"
else # if not SUDO_USER, use /root
	HOME_DIR="/root"
fi
# Create client file and add the server as a peer
echo "[Interface]
PrivateKey = ${CLIENT_PRIV_KEY}
Address = ${CLIENT_WG_IPV4}/32,${CLIENT_WG_IPV6}/128
DNS = ${CLIENT_DNS_1},${CLIENT_DNS_2}
[Peer]
PublicKey = ${SERVER_PUB_KEY}
PresharedKey = ${CLIENT_PRE_SHARED_KEY}
Endpoint = ${ENDPOINT}
AllowedIPs = 0.0.0.0/0,::/0" >>"${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"
# Add the client as a peer to the server
echo -e "\n### Client ${CLIENT_NAME}
[Peer]
PublicKey = ${CLIENT_PUB_KEY}
PresharedKey = ${CLIENT_PRE_SHARED_KEY}
AllowedIPs = ${CLIENT_WG_IPV4}/32,${CLIENT_WG_IPV6}/128" >>"/etc/wireguard/${SERVER_WG_NIC}.conf"
# systemctl restart "wg-quick@${SERVER_WG_NIC}"
echo -e "\nHere is your client config file as a QR Code:"
# qrencode -t ansiutf8 -l L <"${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"
echo "It is also available in ${HOME_DIR}/${SERVER_WG_NIC}-client-${CLIENT_NAME}.conf"