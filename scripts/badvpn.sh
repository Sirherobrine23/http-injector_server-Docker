#!/bin/bash
# clear
fun_bar () {
    comando[0]="$1"
    comando[1]="$2"
    (
    [[ -e $HOME/fim ]] && rm $HOME/fim
    ${comando[0]} -y > /dev/null 2>&1
    ${comando[1]} -y > /dev/null 2>&1
    touch $HOME/fim
    ) > /dev/null 2>&1 &
    while true; do
        for ((i=0; i<18; i++)); do
            echo -ne "Aguarde    \r"
            sleep 0.5s
            echo -ne "Aguarde .  \r"
            sleep 0.5s
            echo -ne "Aguarde .. \r"
            sleep 0.5s
            echo -ne "Aguarde ...\r"
            sleep 0.5s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
    done
    echo -e "OK                 "
}
# [[ $(awk -F" " '{print $2}' /usr/lib/licence) != "@CRAZY_VPN" ]] && exit 0
fun_udp1 () {
    [[ -e "/bin/badvpn-udpgw" ]] && {
        # clear
        echo -e "INICIANDO O BADVPN..."
        fun_udpon () {
            screen -dmS udpvpn /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10
            [[ $(grep -wc "udpvpn" /etc/autostart) = '0' ]] && {
                echo -e "ps x | grep 'udpvpn' | grep -v 'grep' || screen -L -Logfile /tmp/badvpn_log.txt -dmS udpvpn /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000" >> /etc/autostart
            } || {
                sed -i '/udpvpn/d' /etc/autostart
                echo -e "ps x | grep 'udpvpn' | grep -v 'grep' || screen -L -Logfile /tmp/badvpn_log.txt -dmS udpvpn /bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000" >> /etc/autostart
            }
            sleep 1
        }
        fun_bar 'fun_udpon'
        echo -e "BADVPN ATIVO"
        exit 0
    }
}

fun_udp2 () {
    # clear
    echo -e "PARANDO O BADVPN..."
    fun_stopbad () {
        sleep 1
        screen -r -S "udpvpn" -X quit
        screen -wipe 1>/dev/null 2>/dev/null
        [[ $(grep -wc "udpvpn" /etc/autostart) != '0' ]] && {
		    sed -i '/udpvpn/d' /etc/autostart
		}
        sleep 1
    }
    fun_bar 'fun_stopbad'
    echo -e "BADVPN PARADO"
    exit 0
}
[[ $(ps x | grep "udpvpn"|grep -v grep |wc -l) = '0' ]] &&  fun_udp1 || fun_udp2
exit 0