#!/bin/bash
count=0
checkroot() {
if [[ "$(id -u)" -ne 0 ]]; then
    printf "\e[1;77mPlease, run this program as root!\n\e[0m"
    exit 1
fi
}
checkroot
checktor() {
check=$(curl --socks5-hostname localhost:9050 -s https://check.torproject.org > /dev/null; echo $?)
if [[ "$check" -gt 0 ]]; then
printf "\e[1;91mPlease, check your TOR Connection! Just type tor or service tor start\n\e[0m"
exit 1
fi
}
checktor
read -p $'\e[1;92m[::] Change Tor IP after (in seconds): \e[0m' time
function switch() {
killall -HUP tor > /dev/null 2>&1
}
while [[ true ]]; do
let count++
switch
printf "\e[1;92m[*] Tor Ip address changed %s times\e[0m\n" $count
sleep $time
clear
done
