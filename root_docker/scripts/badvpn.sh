#!/bin/bash
BadvpnPort="${1}"
# Check Port
if [[ -z "$BadvpnPort" ]];then BadvpnPort="7300";fi

startBadVPN(){
    screen -dmS badvpn /bin/badvpn-udpgw --listen-addr 0.0.0.0:${BadvpnPort} --max-clients 1000 --max-connections-for-client 10
}

if [[ -e "/bin/badvpn-udpgw" ]]; then
    # clear
    echo -e "Starting BadVPN with port ${BadvpnPort}"
    startBadVPN
    sleep 15s
    if screen -list | grep -q 'badvpn';then echo -e "BadVPN was started"
    else
        echo "BadVPN not started, retrying please wait"
        startBadVPN
        sleep 30s
        if screen -list | grep -q 'badvpn';then echo -e "BadVPN was started"
        else
            echo "BadVPN not started, retrying please wait"
            startBadVPN
            sleep 30s
        fi
    fi
else
    echo "BadVPN was not installed correctly"
fi
exit 0