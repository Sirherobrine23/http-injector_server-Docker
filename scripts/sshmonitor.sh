#!/bin/bash
set -x
database="/root/usuarios.db"
tmp_now=$(printf '%(%H%M%S)T\n')
# echo -ne "*********************************************** $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1) ***********************************************\r"
fun_drop () {
    port_dropbear=`ps aux | grep dropbear | awk NR==1 | awk '{print $17;}'`
    log=/var/log/auth.log
    loginsukses='Password auth succeeded'
    # clear
    pids=`ps ax |grep dropbear |grep  " $port_dropbear" |awk -F" " '{print $1}'`
    for pid in $pids
    do
        # pidlogs=`grep $pid $log |grep "$loginsukses" |awk -F" " '{print $3}'`
        i=0
        # for pidend in $pidlogs
        # do
        #     let i=i+1
        # done
        if [ $pidend ];then
            login=`grep $pid $log |grep "$pidend" |grep "$loginsukses"`
            PID=$pid
            user=`echo $login |awk -F" " '{print $10}' | sed -r "s/'/ /g"`
            waktu=`echo $login |awk -F" " '{print $2"-"$1,$3}'`
            while [ ${#waktu} -lt 13 ]; do
                waktu=$waktu" "
            done
            while [ ${#user} -lt 16 ]; do
                user=$user" "
            done
            while [ ${#PID} -lt 8 ]; do
                PID=$PID" "
            done
            echo "$user $PID $waktu"
        fi
    done
}

    read usline < "$database"
    user="$(echo $usline | cut -d' ' -f1)"
    s2ssh="$(echo $usline | cut -d' ' -f2)"
    if [ "$(cat /etc/passwd| grep -w $user| wc -l)" = "1" ]; then
        sqd="$(ps -u $user | grep sshd | wc -l)"
    else
        sqd=00
    fi
    [[ "$sqd" = "" ]] && sqd=0
    if netstat -nltp|grep 'dropbear'> /dev/null;then
        drop="$(fun_drop | grep "$user" | wc -l)"
    else
        drop=0
    fi
    conex=$(($sqd + $drop))
    if [[ $cnx -gt 0 ]]; then
        tst="$(ps -o etime $(ps -u $user |grep sshd |awk 'NR==1 {print $1}')|awk 'NR==2 {print $1}')"
        tst1=$(echo "$tst" | wc -c)
    if [[ "$tst1" == "9" ]]; then 
        timerr="$(ps -o etime $(ps -u $user |grep sshd |awk 'NR==1 {print $1}')|awk 'NR==2 {print $1}')"
    else
        timerr="$(echo "00:$tst")"
    fi
    if [[ $conex -eq 0 ]]; then
        status=$(echo -e "Offline")
        printf '%-17s%-14s%-10s%s\n' " $user"      "$status" "$conex/$s2ssh" "$timerr" 
    else
        status=$(echo -e "Online")
        printf '%-17s%-14s%-10s%s\n' " $user"      "$status" "$conex/$s2ssh" "$timerr"
    fi
fi
exit