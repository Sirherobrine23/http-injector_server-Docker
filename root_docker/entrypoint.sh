#!/bin/bash
source /etc/PATH
echo "Hello I'm passing by here you add your star in our repository on Github so that the created image remains updated the container, repository: https://github.com/Sirherobrine23/http-injector_server-Docker"
echo "Performing the base configurations, please wait ..."
bash /base/configs.sh &> /tmp/Config.log
echo "Sucess, log file path: /tmp/Config.log"

echo "Configuring users, please wait ..."
username="${ADMIN_USERNAME}" password="${ADMIN_PASSWORD}" bash /base/usuario.sh &> /tmp/users.log
echo "Success, user log path: /tmp/users.log"
# All service status
{
    service --status-all &> /tmp/all_status.txt
    if cat /tmp/all_status.txt | grep 'dropbear' | grep -q ' - ';then
        service dropbear start
    else
        echo "- OK -"
    fi
    # -------------
    if cat /tmp/all_status.txt | grep 'ssh' | grep -q ' - ';then
        service ssh start
    else
        echo "- OK -"
    fi
    # -------------
    if cat /tmp/all_status.txt | grep 'squid' |grep -q ' - ';then
        service squid start
    else
        echo "- OK -"
    fi
    # -------------
} && rm -f /tmp/all_status.txt
echo ""
internal_ips="$(echo $(ifconfig|grep 'inet'|awk '{print $2}')|tr "\n" ",")"
echo "To connect in Docker Image user ssh with ip: ${internal_ips}, $(wget -qO- 'https://ipecho.net/plain')
User: ${ADMIN_USERNAME},
Pass: ${ADMIN_PASSWORD}"
(cd /nodejs ;node speedtest.js)&
while true
do
    /scripts/sshmonitor.sh > /tmp/ssh_monitor
sleep 1s
done
