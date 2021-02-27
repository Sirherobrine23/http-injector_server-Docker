#!/bin/bash
IP=$(wget -qO- 'https://api.ipify.org/?format=json' | jq '.ip'|sed 's|"||g')
cor1='\033[41;1;37m'
cor2='\033[44;1;37m'
scor='\033[0m'

username="$1"
password="$2"
dias="$3"
sshlimiter="$4"

echo "configurações do usuario"
echo ""
# Username
echo -ne "Nome do usuário: $username"
[[ -z $username ]] && {
	echo -e "\n${cor1}Nome de usuário vazio ou invalido!${scor}\n"
	exit 1
}
[[ "$(grep -wc $username /etc/passwd)" != '0' ]] && {
	echo -e "\n${cor1}Este usuário já existe. tente outro nome!${scor}\n"
	exit 1
}
[[ ${username} != ?(+|-)+([a-zA-Z0-9]) ]] && {
	echo -e "\n${cor1}Você digitou um nome de usuário inválido!${scor}"
	echo -e "${cor1}Não use espaços, acentos ou caracteres especiais!${scor}\n"
	exit 1
}
sizemin=$(echo ${#username})
[[ $sizemin -lt 2 ]] && {
	echo -e "\n${cor1}Você digitou um nome de usuário muito curto${scor}"
	echo -e "${cor1}use no mínimo dois caracteres!${scor}\n"
	exit 1
}
sizemax=$(echo ${#username})
[[ $sizemax -gt 10 ]] && {
	echo -e "\n${cor1}Você digitou um nome de usuário muito grande"
	echo -e "${cor1}use no máximo 10 caracteres!${scor}\n"
	exit 1
}

echo ""
# passworld
echo -ne "Senha: *****************"
[[ -z $password ]] && {
	echo -e "\n${cor1}Senha vazia ou invalida!${scor}\n"
	exit 1
}
sizepass=$(echo ${#password})
[[ $sizepass -lt 4 ]] && {
	echo -e "\n${cor1}Senha curta!, use no mínimo 4 caracteres${scor}\n"
	exit 1
}

echo ""
# Days
echo -ne "Dias para expirar: $dias"
[[ -z $dias ]] && {
	echo -e "\n${cor1}Numero de dias vazio!${scor}\n"
	exit 1
}
[[ ${dias} != ?(+|-)+([0-9]) ]] && {
	echo -e "\n${cor1}Você digitou um número de dias inválido!${scor}\n"
	exit 1
}
[[ $dias -lt 1 ]] && {
	echo -e "\n${cor1}O número deve ser maior que zero!${scor}\n"
	exit 1
}

echo ""
# connections
echo -ne "Limite de conexões: $sshlimiter"
[[ -z $sshlimiter ]] && {
	echo -e "\n${cor1}Você deixou o limite de conexões vazio!${scor}\n"
	exit 1
}
[[ ${sshlimiter} != ?(+|-)+([0-9]) ]] && {
	echo -e "\n${cor1}Você digitou um número de conexões inválido!${scor}\n"
	exit 1
}
[[ $sshlimiter -lt 1 ]] && {
	echo -e "\n${cor1}Número de conexões simultâneas deve ser maior que zero!${scor}\n"
	exit 1
}
final=$(date "+%Y-%m-%d" -d "+$dias days")
gui=$(date "+%d/%m/%Y" -d "+$dias days")
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
useradd -e $final -M -s /bin/false -p $pass $username >/dev/null 2>&1 &
echo "$password" >/etc/SSHPlus/senha/$username
echo "$username $sshlimiter" >>/root/usuarios.db

echo -e "IP:                 $IP"
echo -e "Usuário:            $username"
echo -e "Senha:              *****************"
echo -e "Expira em:          $gui"
echo -e "Limite de conexões: $sshlimiter"