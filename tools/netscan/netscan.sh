#!/bin/bash
# Netscan: Anonymous & Multi-threaded network port scan in shellscript using Netcat e proxychains
# Author: thelinuxchoice
# Github: github.com/thelinuxchoice/netscan 
# Instagram: @thelinuxchoice
trap 'partial;exit 1' 2


partial() {

if [[ -n "$threads" ]]; then
printf "\n"
printf "\e[1;91m [*] Waiting threads..\n\e[0m"
wait $pid > /dev/null 2>&1 ;
sleep 6
if [[ -e logip ]]; then

countip=$(wc -l logip | cut -d " " -f1)
printf "\e[1;92m[*] IPs Found:\e[0m\e[1;77m %s\e[0m\n" $countip 
cat logip >> "logip.$session"
wait $!
rm -rf logip
printf "\e[1;92m [*] Saved:\e[0m\e[1;77m logip.%s\e[0m\n" $session
fi
default_session_ans="Y"
printf "\n\e[1;77m [?] Save session \e[0m\e[1;92m %s \e[0m" $session
read -p $'\e[1;77m? [Y/n]: \e[0m' session_ans
session_ans="${session_ans:-${default_session_ans}}"
if [[ "$session_ans" == "Y" || "$session_ans" == "y" || "$session_ans" == "yes" || "$session_ans" == "Yes" ]]; then
if [[ ! -d sessions ]]; then
mkdir sessions
fi
printf "session=\"%s\"\ncount=\"%s\"\nport=\"%s\"\ntargets=\"targets-%s\"\n" $session $count $port $session > sessions/session.$session
if [[ -e targets-$session ]]; then
mv targets-$session sessions/targets-$session
fi
printf "\e[1;77m[*] Session saved.\e[0m\n"
printf "\e[1;92m[*] Use ./netscan.sh --resume\n"
else
exit 1
fi
else
exit 1
fi
}
checktor() {

check_tor=$(curl --socks5-hostname localhost:9050 -s https://www.google.com > /dev/null; echo $?)
if [[ "check_tor" -gt 0 ]]; then
printf "\e[1;91mCheck your Tor connection!\n"
exit 1 
fi
}



usetor() {
default_use_tor="Y"
read -p $'\e[1;92mUse Tor? \e[0m\e[1;77m[Y/n]: \e[0m' use_tor
use_tor="${use_tor:-${default_use_tor}}"

if [[ $use_tor == "Y" || $use_tor == "Yes" || $use_tor == "y" || $use_tor == "yes" ]]; then
command1="proxychains nc"
checktor
else
command1="nc"
fi


}

banner() {

printf "\e[1;92m  _   _      _   ____                   \e[0m\n"
printf "\e[1;92m | \ | | ___| |_/ ___|  ___ __ _ _ __   \e[0m\n"
printf "\e[1;92m |  \| |/ _ \ __\___ \ / __/ _\` | '_ \  \e[0m\n"
printf "\e[1;92m | |\  |  __/ |_ ___) | (_| (_| | | | | \e[0m\n"
printf "\e[1;92m |_| \_|\___|\__|____/ \___\__,_|_| |_| \e[0m\e[1;77mv1.2\e[0m\n"
printf "\n"
printf "\e[1;100m  Author: thelinuxchoice (Github/Instagram) \e[0m\n\n"


}


dependencies() {

command -v proxychains > /dev/null 2>&1 || { echo >&2 "I require Proxychains. Run: apt-get install tor. Aborting."; exit 1; }
command -v nc > /dev/null 2>&1 || { echo >&2 "I require NetCat. Run: apt-get install nc. Aborting."; exit 1; }

}


scan() {
#banner
dependencies
#checktor
read -p $'\e[1;37m[::] Put range ip part 1/4 \e[0m\e[91m(e.g.:192 255)  \e[0m\e[1;92m -> \e[0m' r1
read -p $'\e[1;37m[::] Put range ip part 2/4 \e[0m\e[91m(e.g: 168 255)  \e[0m\e[1;92m -> \e[0m' r2
read -p $'\e[1;37m[::] Put range ip part 3/4 \e[0m\e[91m(e.g.: 1 255)   \e[0m\e[1;92m -> \e[0m' r3
read -p $'\e[1;37m[::] Put range ip part 4/4 \e[0m\e[91m(e.g.: 10 255)  \e[0m\e[1;92m -> \e[0m' r4
default_port=22
read -p $'\e[1;37m[::] Port to scan\e[0m \e[1;91m(Default 22):\e[0m ' port
port="${port:-${default_port}}"
number=$RANDOM
default_session="session-$number"
read -p $'\e[1;37m[::] Session name \e[1;91m(Default:\e[0m '$default_session'): ' session
session="${session:-${default_session}}"
default_threads=100
read -p $'\e[1;37m[::] Numbers of Threads to scan \e[1;91m(Default 100):\e[0m \e[0m' threads
threads="${threads:-${default_threads}}"
for x in $(seq $r1);do for y in $(seq $r2);do for z in $(seq $r3);do for w in $(seq $r4);do
printf "%s.%s.%s.%s\n" $x $y $z $w >> targets-$session
done done done done

if [[ -e logip ]]; then
rm -rf logip;
fi
count_target=$(wc -l targets-$session | cut -d " " -f1)
printf "\e[1;92m[*] Targets:\e[0m\e[1;77m %s\e[0m\n" $count_target
printf "\e[1;92m[*] Starting scanner...\e[0m\n"
sleep 3
count=0
startline=1
endline="$threads"
while [ $count -lt $count_target ]; do
for target in $(sed -n ''$startline','$endline'p' targets-$session); do
let count++
printf "\e[1;93mScanning target:\e[0m\e[77m %s \e[0m\e[1;93m(\e[0m\e[77m%s\e[0m\e[1;93m/\e[0m\e[77m%s\e[0m\e[1;93m)\e[0m\n" $target $count $count_target
{(trap '' SIGINT && check=$($command1 $target $port -v -z -w5 > /dev/null 2>&1; echo $?); if [[ $check == "0" ]]; then echo $target >> logip; fi; ) } & done; pid=$! ; wait $!;
let startline+=$threads
let endline+=$threads

done

if [[ -e logip ]]; then

countip=$(wc -l logip | cut -d " " -f1)
printf "\e[1;92m[*] IPs Found:\e[0m\e[1;77m %s\e[0m\n" $countip 
ssfile=logip.$session
sfile=$(mv logip $ssfile | echo $ssfile)
printf "\e[1;92m [*] Saved:\e[0m\e[1;77m %s\e[0m\n" $sfile

else
printf "\e[1;91m[!] No Open ports found in this IP range!\e[0m\n"
exit 1
fi
}


function scan_resume() {
checktor
count_target=$(wc -l sessions/$targets | cut -d " " -f1)
printf "\e[1;92m[*] Targets:\e[0m\e[1;77m %s\e[0m\n" $count_target
printf "\e[1;92m[*] Starting scanner...\e[0m\n"
sleep 3
startline=$((count+1))
endline=$((count+threads))
while [ $((count2)) -lt $count_target ]; do
for target in $(sed -n ''$startline','$endline'p' sessions/$targets); do
count21=0
count2=$((count+count21+1))
#count_ip=$(grep -n -x "$target" "sessions/$targets" | cut -d ":" -f1)
printf "\e[1;93mScanning target:\e[0m\e[77m %s \e[0m\e[1;93m(\e[0m\e[77m%s\e[0m\e[1;93m/\e[0m\e[77m%s\e[0m\e[1;93m)\e[0m\n" $target $count2 $count_target
let count++
let count21++
{(trap '' SIGINT && check=$($command1 $target $port -v -z -w5 > /dev/null 2>&1; echo $?); if [[ $check == "0" ]]; then echo $target >> logip; fi; ) } & done; pid=$! ; wait $!;
let startline+=$threads
let endline+=$threads

done

if [[ -e logip ]]; then

countip=$(wc -l logip | cut -d " " -f1)
printf "\e[1;92m[*] IPs Found:\e[0m\e[1;77m %s\e[0m\n" $countip 
cat logip >> logip.$session
rm -rf logip
printf "\e[1;92m [*] Saved:\e[0m\e[1;77m logip.%s\e[0m\n" $session
else
printf "\e[1;91m[!] No Open ports found in this IP range!\e[0m\n"
exit 1
fi



}


function resume() {

#banner 
dependencies
usetor
countern=1
if [[ ! -d sessions ]]; then
printf "\e[1;91m[*] No sessions\n\e[0m"
exit 1
fi
printf "\e[1;92mFiles sessions:\n\e[0m"
for list in $(ls sessions/session*); do
IFS=$'\n'
source $list
printf "\e[1;92m%s\e[0m\e[1;77m: \e[0m %s \e[1;92mPort:\e[0m %s \e[1;92mLast position:\e[0m %s\n" $countern $session $port $count
let countern++
done
read -p $'\e[1;92mChoose a session number: \e[0m' fileresume
source $(ls sessions/session* | sed ''$fileresume'q;d')
default_threads=100
read -p $'\e[1;37m[::] Numbers of Threads to scan \e[1;91m(Default 100):\e[0m \e[0m' threads
threads="${threads:-${default_threads}}"

printf "\e[1;92m[*] Resuming session :\e[0m \e[1;77m%s\e[0m\n" $session
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
scan_resume


}

case "$1" in --resume) resume ;; *)
usetor
scan

esac

