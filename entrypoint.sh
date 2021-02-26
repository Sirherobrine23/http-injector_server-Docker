#!/bin/bash
EXTERNAL_IP=$(wget -qO- 'https://api.ipify.org/?format=json' | jq '.ip'|sed 's|"||g')
echo "acl externalIP dstdomain -i ${EXTERNAL_IP}
acl all src 0.0.0.0/0

# Allow
http_access allow all
http_access allow externalIP

# Deny
http_access deny all

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
pipeline_prefetch off" > /etc/squid3/squid.config
# All service status
service --status-all

service dropbear start
service ssh start
service squid start

# All service status
service --status-all

# Usernamos
username="${ADMIN_USERNAME}"
password="${ADMIN_PASSWORD}"
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password);
useradd -m -p "$pass" "$username";
addgroup ${username} sudo;
usermod --shell /bin/bash ${username}

internal_ips="$(echo $(ifconfig|grep 'inet'|awk '{print $2}')|tr "\n" " ")"
echo "To connect in Docker Image user ssh with ip: ${internal_ips} ${EXTERNAL_IP}
User: ${ADMIN_USERNAME},
Pass: ****************
"
node /node_scripts/set_users.js
echo "User exit code: $?"
badvpn.sh && {
    while true
    do
        sshmonitor.sh
    sleep 5s
    done
}