#!/bin/bash
source /etc/wireguard/params
ENDPOINT="${SERVER_PUB_IP}:${SERVER_PORT}"
echo ""
echo "Tell me a name for the client."
echo "The name must consist of alphanumeric character. It may also include an underscore or a dash and can't exceed 15 chars."
until [[ ${CLIENT_NAME} =~ ^[a-zA-Z0-9_-]+$ && ${CLIENT_EXISTS} == '0' && ${#CLIENT_NAME} -lt 16 ]]; do
	# read -rp "Client name: " -e CLIENT_NAME
	CLIENT_NAME="${1}"
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