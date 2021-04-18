#!/bin/bash
IP=$(wget -qO- 'https://ipecho.net/plain')
cor1='\033[41;1;37m'
username="$1"
password="$2"
dias="$3"
sshlimiter="$4"

# Username
[[ -z $username ]] && {
	echo "Empty or invalid username!";
	exit 0
}
[[ "$(grep -wc $username /etc/passwd)" != '0' ]] && {
	echo "This user already exists. try another name!";
	exit 0
}
[[ ${username} != ?(+|-)+([a-zA-Z0-9]) ]] && {
	echo "You entered an invalid username!";
	echo "Do not use spaces, accents or special characters!";
	exit 0
}
sizemin=$(echo ${#username})
[[ $sizemin -lt 2 ]] && {
	echo "You entered a very short username";
	echo "use at least two characters!";
	exit 0
}
sizemax=$(echo ${#username})
[[ $sizemax -gt 10 ]] && {
	echo "You entered a very long username";
	echo "use a maximum of 10 characters!";
	exit 0
}
# Passworld
[[ -z $password ]] && {
	echo "Password empty or invalid!";
	exit 0
}
sizepass=$(echo ${#password})
[[ $sizepass -lt 4 ]] && {
	echo "Short password !, use at least 4 characters";
	exit 0
}

# Days
[[ -z $dias ]] && {
	echo "Number of days empty!";
	exit 0
}
[[ ${dias} != ?(+|-)+([0-9]) ]] && {
	echo "You have entered an invalid number of days!";
	exit 0
}
[[ $dias -lt 1 ]] && {
	echo "The number must be greater than zero!";
	exit 0
}

# connections
[[ -z $sshlimiter ]] && {
	echo "You left the connection limit empty!";
	exit 0
}
[[ ${sshlimiter} != ?(+|-)+([0-9]) ]] && {
	echo "You have entered an invalid connection number!";
	exit 0
}
[[ $sshlimiter -lt 1 ]] && {
	echo "Number of simultaneous connections must be greater than zero!";
	exit 0
}

final=$(date "+%Y-%m-%d" -d "+$dias days")
gui=$(date "+%d/%m/%Y" -d "+$dias days")
pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
mkdir /tmp/senha

if (useradd -e $final -M -s /bin/false -p $pass $username)
then
	echo "$password" > /tmp/senha/$username
	echo "$username $sshlimiter" >> /root/usuarios.db
	echo "$username - Ok"
else
	echo "$username - Fail"
fi

exit