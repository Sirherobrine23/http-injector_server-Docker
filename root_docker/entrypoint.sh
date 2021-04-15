#!/bin/bash
source /etc/PATH
echo "Hello I'm passing by here you add your star in our repository on Github so that the created image remains updated the container, repository: https://github.com/Sirherobrine23/http-injector_server-Docker"

echo "Performing the base configurations, please wait ..."

echo "Configuring users, please wait ..."
username="${ADMIN_USERNAME}" password="${ADMIN_PASSWORD}"
{
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password);
    useradd -m -p "$pass" "$username";
    addgroup ${username} sudo;
    usermod --shell /usr/bin/zsh --home /tmp/${username} ${username}
    echo "${username}   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
}

(
    cd /nodejs/
    node Setup.js
)

# Start Services
service dropbear start &> /dev/nul
service ssh start &> /dev/nul
service squid start &> /dev/nul
sleep 30s

service --status-all &> /tmp/status
cat /tmp/status | grep 'dropbear'
cat /tmp/status | grep 'ssh'
cat /tmp/status | grep 'squid'

echo ""
internal_ips="$(echo $(ifconfig|grep 'inet'|awk '{print $2}'))"
echo "To connect in Docker Image user ssh with ip: ${internal_ips} $(wget -qO- 'https://ipecho.net/plain')
User: ${ADMIN_USERNAME},
Pass: ${ADMIN_PASSWORD}"
/scripts/badvpn.sh
while true
do
    /scripts/sshmonitor.sh > /tmp/ssh_monitor
    if ! (ps aux |grep -v "grep"| grep -q 'sshd');then ps aux;echo "OpenSSH is stopped, exiting";exit 3;fi
    if ! (ps aux |grep -v "grep"| grep -q 'squid');then ps aux;echo "Squid is stopped, leaving";exit 4;fi
    if ! (ps aux |grep -v "grep"| grep -q 'dropbear');then ps aux;echo "Dropebear is stopped, exiting";exit 2;fi
    sleep 1s
done
