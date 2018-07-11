# Multi-Tor Tool
# Coded by @thelinuxchoice
# Github: github.com/thelinuxchoice
# Instagram: @thelinuxchoice
# v1.1


readinst() {
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Tor instances (default: 1): \e[0m' inst
}



checktor() {
let i=1
while [[ $i -le $inst ]]; do
port=$((9050+$i))
printf "\e[1;92m[*] Checking Tor connection on port:\e[0m\e[1;77m %s\e[0m..." $port
checkcount=0 
check=$(curl --socks5-hostname localhost:$port -s https://www.google.com > /dev/null; echo $?) 
if [[ "$check" -gt 0 ]]; then 
printf "\e[1;91mFAIL!\e[0m\n" 
else 
printf "\e[1;92mOK!\e[0m\n" 
let checkcount++ 
fi
i=$((i+1))
done


}

status() {

checktorprocess=$(pidof tor > /dev/null; echo $?)
if [[ $checktorprocess == 0 ]]; then
printf "\e[1;92m[*] Tor is running!\e[0m\n"
checktor
else
printf "\e[1;93m[*] Tor is NOT running!\e[0m\n"
fi



}


multitor() {


if [[ ! -d multitor ]]; then 
mkdir multitor;
fi
default_ins="1"
inst="${inst:-${default_inst}}"

i=1
while [[ $i -le $inst ]]; do
port=$((9050+$i))
printf "SOCKSPort %s\nDataDirectory /var/lib/tor%s" $port $i > multitor/multitor$i 
printf "\e[1;92m[*] Starting Tor on port:\e[0m\e[1;77m 905%s\e[0m\n" $i 
tor -f multitor/multitor$i > /dev/null &
sleep 10
i=$((i+1))
done
checktor
}

stoptor() {

killall -2 tor
printf "\e[1;92m[*] All Tor connection stopped.\e[0m\n"
}


case "$1" in --start) readinst; multitor ;; --stop) stoptor ;; --status) status ;; *)

printf "\e[1;92mUsage: ./multitor.sh --start --stop\e[0m\n"

esac


