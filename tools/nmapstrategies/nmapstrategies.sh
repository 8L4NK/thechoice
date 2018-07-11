#!/bin/bash
# ig: @thelinuxchoice
if [[ "$(id -u)" -ne 0 ]]; then
   printf ".:: Please, run this program as root!\n"
   exit 1
fi

printf "\e[1;32m  :: Choice your nmap strategy :: \e[0m\n"
printf "\n"
printf '\e[1;32m[*] Zenmap strategies:\e[0m\n'
#printf '\n'
printf '\e[0;32m 1) Intense Scan \e[0m\n'
printf '\e[0;32m 2) Intense Scan, Plus UDP\e[0m\n'
printf '\e[0;32m 3) Intense Scan, all TCP ports\e[0m\n'
printf '\e[0;32m 4) Intense Scan, no ping\e[0m\n'
printf '\e[0;32m 5) Ping scan\e[0m\n'
printf '\e[0;32m 6) Quick Scan\e[0m\n'
printf '\e[0;32m 7) Quick Scan Plus\e[0m\n'
printf '\e[0;32m 8) Quick traceroute\e[0m\n'
printf '\e[0;32m 9) Regular Scan\e[0m\n'
printf '\e[0;32m 10) Slow comprehensive scan\e[0m\n'
printf '\n'
printf '\e[1;32m[*] Firewall/IDS Evasion and Spoofing\e[0m\n'
#printf '\n'
printf '\e[0;32m 11) Fragmentation\e[0m\n'
printf '\e[0;32m 12) Change default MTU size number\e[0m\n'
printf '\e[0;32m 13) Fragmentation + MTU\e[0m\n'
printf '\e[0;32m 14) Generates a random number of decoys\e[0m\n'
printf '\e[0;32m 15) MAC Address Spoofing\e[0m\n'
printf '\n'
printf '\e[1;32m[*] Nmap Scripting Engine (NSE)\e[0m\n'
#printf '\n'
printf '\e[0;32m 16) Not intrusive \e[0m\n'
printf '\e[0;32m 17) Default\e[0m\n'
printf '\e[0;32m 18) Default or safe \e[0m\n'
printf '\e[0;32m 19) Default and safe \e[0m\n'
printf '\e[0;32m 20) All scripts \e[0m\n'
printf '\n' 
printf '\e[1;32m[*] Miscelaneous\e[0m\n'
#printf '\n'
printf '\e[0;32m 21) Detect Service Version  \e[0m\n'
printf '\e[0;32m 22) Operating System Scan \e[0m\n'
printf '\e[0;32m 23) OS and Service Detect \e[0m\n'
printf '\e[0;32m 24) Version Detect\e[0m\n'
printf '\e[0;32m 25) Full Port Scan (TCP) \e[0m\n'
printf '\e[0;32m 26) Full Port Scan (UDP/Very Slow)\e[0m\n'
printf '\e[0;32m 27) Most Common Ports (TCP) \e[0m\n'
printf '\e[0;32m 28) Most Common Ports (UDP) \e[0m\n'
printf '\e[0;32m 29) Faster Regular Scan \e[0m\n'
printf '\n'
printf '\e[0;31m One line: bash tools/nmapstrategies/nmapstrategies.sh [target] [number] \e[0m\n\n'

if [[ "$2" -eq "" ]]; then
read -e -p "Number>" scan
else
scan="$2"
fi
if [[ "$1" == "" ]]; then
read -e -p "Target>" target
else
target="$1"
fi
 
if [[ $scan == '1' ]]
   then
	nmap -v -T4 -A -v $target

elif [[ $scan == '2' ]]
    then
	nmap -v -sS -sU -T4 -A -v $target

elif [[ $scan == '3' ]]
    then
	nmap -v -p 1-65535 -T4 -A -v $target

elif [[ $scan == '4' ]]
    then
	nmap -v -T4 -A -v -Pn $target

elif [[ $scan == '5' ]]
    then
	nmap -v -sn $target

elif [[ $scan == '6' ]]
    then
	nmap -v -T4 -F $target

elif [[ $scan == '7' ]]
    then
	nmap -v -v -sV -T4 -O -F --version-light $target

elif [[ $scan == '8' ]]
    then
	nmap -v -sn --traceroute $target

elif [[ $scan == '9' ]]
    then
	nmap -v $target

elif [[ $scan == '10' ]]
    then
	nmap -v -sS -sU -T4 -A -v -PE -PP -PS80,443 -PA3389 -PU40125 -PY -g 53 --script "default or (discovery and safe)" $target

elif [[ $scan == '11' ]]
    then
	nmap -v -f

elif [[ $scan == '12' ]]
    then
default_mtu="24"
    read -e -p "MTU Size (Default 24):" mtu
mtu="${mtu:-${default_mtu}}"
	nmap -v --mtu $mtu $target

elif [[ $scan == '13' ]]
    then
default_mtu="24"
    read -e -p "MTU Size (Default 24):" mtu
mtu="${mtu:-${default_mtu}}"
	nmap -v -f --mtu $mtu $target

elif [[ $scan == '14' ]]
    then
	nmap -v -D RND:10 $target

elif [[ $scan == '15' ]]
    then
	nmap -v --spoof-mac Cisco $target

elif [[ $scan == '16' ]]
    then
	nmap -v --script "not intrusive" $target

elif [[ $scan == '17' ]]
    then
	nmap -v --script "default" $target

elif [[ $scan == '18' ]]
    then
	nmap -v --script "default or safe" $target

elif [[ $scan == '19' ]]
    then
	nmap -v --script "default and safe" $target

elif [[ $scan == '20' ]]
    then
	nmap -v --script "all" $target

elif [[ $scan == '21' ]]
    then
	nmap -v -sV -T4 -Pn -oG ServiceDetect  $target

elif [[ $scan == '22' ]]
    then
	nmap -v -O -T4 -Pn -oG OSDetect  $target

elif [[ $scan == '23' ]]
    then
	nmap -v -O -sV -T4 -Pn -p U:53,111,137,T:21-25,80,139,8080 -oG OS_Service_detect  $target


elif [[ $scan == '24' ]]
    then
	nmap -v -sS -sV -T5 -F -A -O $target

elif [[ $scan == '25' ]]
    then
	nmap -v -sS -T4 -Pn -p 0-65535 -oN FullTCP  $target

elif [[ $scan == '26' ]]
    then
	nmap -v -sU -T4 -Pn -p 0-65535 -oN FullUDP  $target

elif [[ $scan == '27' ]]
    then
	nmap -v -sS -T4 -Pn -oG TopTCP  $target

elif [[ $scan == '28' ]]
    then
	nmap -v -sS -T4 -Pn -oG TopUDP  $target

elif [[ $scan == '29' ]]
    then

	nmap -v -T5 $target



else
    echo "incorrect number"
fi
