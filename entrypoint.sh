#!/bin/bash
mkdir /home/{config,ssl}
apt install -y linux-headers-$(uname -r)
ln -s /etc/wireguard/ /home/config/wireguard
/setup/wireguard_setup.sh
EXTERNAL_IP=$(wget -qO- 'https://api.ipify.org/?format=json' | jq '.ip'|sed 's|"||g')
EXTERNAL_IP2=$(wget -qO- 'https://ipecho.net/plain')
[ "${EXTERNAL_IP2}" == "${EXTERNAL_IP}" ] && IP_="${EXTERNAL_IP}"||IP_="${EXTERNAL_IP2}"
[[ ${IP_} == "" ]] && {
    echo "Erro in get external IP"
    exit 2
}
set -e
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
    
} &> /tmp/service_status
cat /tmp/service_status |grep -v 'BCP 177 violation. Detected non-functional IPv6 loopback.'|grep -v "0.0.0.0/0' needs to be replaced by the term 'all'."|grep -v \
"SECURITY NOTICE: Overriding config setting. Using 'all' instead."|grep -v "WARNING: (B) '::/0' is a subnetwork of (A) '::/0'"|grep -v "(B) '::/0' is a subnetwork of (A) '::/0'"|\
grep -v "WARNING: (B) '::/0' is a subnetwork of (A) '::/0'"|grep -v "WARNING: because of this '::/0' is ignored to keep splay tree searching predictable"|\
grep -v "WARNING: You should probably remove '::/0' from the ACL named 'all'"|grep .
rm -f /tmp/service_status
(cd /setup
for Install in *;do
    chmod a+x "${Install}";
    ./${Install};
    echo "./${Install}";
done )
# All service status
{
    service --status-all &> /tmp/all_status.txt
    if cat /tmp/all_status.txt | grep 'dropbear' | grep -q ' - ';then
        service dropbear start
    fi
    cat /tmp/all_status.txt | grep 'dropbear'
    # -------------
    if cat /tmp/all_status.txt | grep 'ssh' | grep -q ' - ';then
        service ssh start
    fi
    cat /tmp/all_status.txt | grep 'ssh'
    # -------------
    if cat /tmp/all_status.txt | grep 'squid' |grep -q ' - ';then
        service squid start
    fi
    cat /tmp/all_status.txt | grep 'squid'
    # -------------
} && rm -f /tmp/all_status.txt
node /node_scripts/set_users.js || exit 23
# wireguard_start.sh
badvpn.sh
{
    username="${ADMIN_USERNAME}"
    password="${ADMIN_PASSWORD}"
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password);
    useradd -m -p "$pass" "$username";
    addgroup ${username} sudo;
    usermod --shell /bin/bash --home /home/config/${username} ${username}
    echo "${ADMIN_USERNAME}   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
} &> /tmp/config_user
# Usernames
internal_ips="$(echo $(ifconfig|grep 'inet'|awk '{print $2}')|tr "\n" " ")"
echo "To connect in Docker Image user ssh with ip: ${internal_ips} ${IP_}
User: ${ADMIN_USERNAME},
Pass: ${ADMIN_PASSWORD}"
while true
do
    sshmonitor.sh > /tmp/ssh_monitor
sleep 1s
done