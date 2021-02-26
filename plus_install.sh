#!/bin/bash
_lnk=$(echo 'z1:y#x.5s0ul&p4hs$s.0a72d*n-e!v89e032:3r'| sed -e 's/[^a-z.]//ig'| rev);
_Ink=$(echo '/3×u3#s87r/l32o4×c1a×l1/83×l24×i0b×'|sed -e 's/[^a-z/]//ig');
_1nk=$(echo '/3×u3#s×87r/83×l2×4×i0b×'|sed -e 's/[^a-z/]//ig')
cd $HOME
fun_bar () {
    comando[0]="$1"
    comando[1]="$2"
    (
    [[ -e $HOME/fim ]] && rm $HOME/fim
        ${comando[0]} -y > /dev/null 2>&1
        ${comando[1]} -y > /dev/null 2>&1
        touch $HOME/fim
    ) > /dev/null 2>&1 &
    echo -ne "AGUARDE\r"
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
    sleep 1s
    echo -ne "AGUARDE\r"
    done
    echo "OK                                  "
}
function verif_key () {
krm=$(echo '5:q-3gs2.o7%8:1'|rev); chmod +x $_Ink/list > /dev/null 2>&1
    [[ ! -e "$_Ink/list" ]] && {
        echo -n "KEY INVÁLIDA"
        # rm -rf $HOME/Plus > /dev/null 2>&1
        sleep 2
        exit 1
    }
}
x='y'

[[ $x = @(n|N) ]] && exit
sed -i 's/Port 22222/Port 22/g' /etc/ssh/sshd_config  > /dev/null 2>&1
service ssh restart  > /dev/null 2>&1
echo -ne "VERIFICANDO...\n" ; rm $_Ink/list > /dev/null 2>&1; wget -P $_Ink https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/SSHPLUS-MANAGER-FREE/master/Install/list > /dev/null 2>&1; verif_key
sleep 3s
echo "/bin/menu" > /bin/h && chmod +x /bin/h > /dev/null 2>&1
echo "apt-get update -y
apt-get upgrade -y
wget https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/SSHPLUS-MANAGER-FREE/master/Plus
chmod 777 Plus
./Plus" > /bin/sshplus && chmod +x /bin/sshplus > /dev/null 2>&1
rm versao* > /dev/null 2>&1
wget https://raw.githubusercontent.com/AAAAAEXQOSyIpN2JZ0ehUQ/SSHPLUS-MANAGER-FREE/master/versao > /dev/null 2>&1
#-----------------------------------------------------------------------------------------------------------------
echo -n "KEY VALIDA"
sleep 1s
echo ""
awk -F : '$3 >= 500 { print $1 " 1" }' /etc/passwd | grep -v '^nobody' > $HOME/usuarios.db
[[ "$optiondb" = '2' ]] && awk -F : '$3 >= 500 { print $1 " 1" }' /etc/passwd | grep -v '^nobody' > $HOME/usuarios.db
# tput setaf 7 ; tput setab 4 ; tput bold ; printf '%35s%s%-18s\n' " AGUARDE A INSTALAÇÃO" ; tput sgr0
fun_attlist () {
apt-get update -y
[[ ! -d /usr/share/.plus ]] && mkdir /usr/share/.plus
echo "crz: $(date)" > /usr/share/.plus/.plus
}
fun_bar 'fun_attlist'
inst_pct () {
_pacotes=("bc" "screen" "nano" "unzip" "lsof" "netstat" "net-tools" "dos2unix" "nload" "jq" "curl" "figlet" "python3" "python-pip")
for _prog in ${_pacotes[@]}; do
apt install $_prog -y
done
pip install speedtest-cli
}
fun_bar 'inst_pct'
fun_bar "$_Ink/list $_lnk $_Ink $_1nk $key"
# rm $HOME/Plus && cat /dev/null > ~/.bash_history && history -c