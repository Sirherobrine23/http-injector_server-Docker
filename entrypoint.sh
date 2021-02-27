#!/bin/bash
if ! echo ${PATH} |grep -q ':/scripts';then exit 1;fi
EXTERNAL_IP=$(wget -qO- 'https://api.ipify.org/?format=json' | jq '.ip'|sed 's|"||g')
[[ ${EXTERNAL_IP} == "" ]] && {
    echo "Erro in get external IP"
    exit 2
}
set -e
echo "acl all src 0.0.0.0/0

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
    
} &> /tmp/service_status && cat /tmp/service_status && rm -f /tmp/service_status

# All service status
{
    service dropbear start
    service ssh start
    service squid start
    # -------------
    # -------------
    service --status-all &>> /tmp/all_status.txt
    if cat /tmp/all_status.txt | grep 'dropbear' | grep -q '[ - ]';then
        service dropbear start
    else
        service dropbear restart
    fi
    cat /tmp/all_status.txt | grep 'dropbear'
    # -------------
    if cat /tmp/all_status.txt | grep 'ssh' | grep -q '[ - ]';then
        service ssh start
    else
        service ssh restart
    fi
    cat /tmp/all_status.txt | grep 'ssh'
    # -------------
    if cat /tmp/all_status.txt | grep 'squid' |grep -q '[ - ]';then
        service squid start
    else
        service squid restart
    fi
    cat /tmp/all_status.txt | grep 'squid'
    # -------------
} && rm -f /tmp/all_status.txt


# Usernamos
{
    username="${ADMIN_USERNAME}"
    password="${ADMIN_PASSWORD}"
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password);
    useradd -m -p "$pass" "$username";
    addgroup ${username} sudo;
    usermod --shell /bin/bash ${username}
} &> /tmp/config_user

internal_ips="$(echo $(ifconfig|grep 'inet'|awk '{print $2}')|tr "\n" " ")"
echo "To connect in Docker Image user ssh with ip: ${internal_ips} ${EXTERNAL_IP}
User: ${ADMIN_USERNAME},
Pass: ****************"
node /node_scripts/set_users.js || exit 23
badvpn.sh && {
    while true
    do
        sshmonitor.sh > /tmp/ssh_monitor
    sleep 1s
    done
}