#!/bin/bash
# @thelinuxchoice
checkroot() {
if [[ "$(id -u)" -ne 0 ]]; then
    printf "\e[1;93mPlease, run this program as root!\e[0m\n"
    exit 1
fi
}
dependencies() {

command -v ipset > /dev/null 2>&1 || { echo >&2 "I require ipset but it's not installed. Install it. Aborting."; exit 1; }

}

start() {
dependencies
checkroot

#declare -a dependencies=("/sbin/ipset");
#for package in "${dependencies[@]}"; do
#   if ! hash "$package" 2> /dev/null; then
#     printf "'$package' isn't installed. apt-get install -y '$package'\n";
#     exit 1
#   fi
#done
#YOUR_IP=$(curl -s ifconfig.me)
YOUR_IP=$(curl -s dnsleak.com | grep -o 'address:.*' | cut -d '<' -f1 | cut -d " " -f2)
printf "\e[1;77m[*] Configuring ipset..."
/sbin/ipset -q -N tor iphash
wget -q https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$YOUR_IP -O - | /bin/sed '/^#/d' | while read IP
do
/sbin/ipset -q -A tor $IP
done
if [ ! -d "/etc/iptables" ]; then
/bin/mkdir "/etc/iptables"
/sbin/ipset -q save -f /etc/iptables/ipset.rules
printf "\e[1;92mDone\e[0m\e[1;77m (saved: /etc/iptables/ipset.rules\e[0m\n"
fi
/sbin/ipset -q save -f /etc/iptables/ipset.rules
printf "\e[1;92mDone\e[0m\e[1;77m (saved: /etc/iptables/ipset.rules\e[0m\n"
printf "\e[1;77m[*] Configuring iptables..."
checkiptables=$(/sbin/iptables --list | /bin/grep -o "tor src")
if [[ $checkiptables == "" ]]; then
/sbin/iptables -A INPUT -m set --match-set tor src -j DROP;
fi
if [ ! -e "/etc/iptables/rules.v4" ]; then
/usr/bin/touch "/etc/iptables/rules.v4"
/sbin/iptables-save > /etc/iptables/rules.v4
printf "\e[1;92mDone \e[1;77m(saved: /etc/iptables/rules.v4)\e[0m\n"
else
/sbin/iptables-save > /etc/iptables/rules.v4
printf "\e[1;92mDone\e[0m\e[1;77m (saved: /etc/iptables/rules.v4)\e[0m\n"
fi
}

stop() {
checkroot
/sbin/iptables -D INPUT -m set --match-set tor src -j DROP
/sbin/ipset destroy tor
printf "\e[1;77m[*] Blocktor stopped,rules removed\e[0m\n"
}

status() {

checktor=$(iptables -L | grep -o "tor")

if [[ $checktor == *'tor'* ]]; then
printf "\e[1;92m[*] BlockTor is Running!\e[0m\n"
else
printf "\e[1;93m[*] BlockTor is NOT Running!\e[0m\n"
fi
}
case "$1" in --start) start ;; --stop) stop ;; --status) status ;; *)
printf "Usage: sudo ./blocktor.sh --start / --stop\n"
exit 1
esac
