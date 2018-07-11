#!/usr/bin/env bash
# DebianTor based on Kalitorify: https://github.com/brainfucksec/kalitorify
## Network settings
# UID of tor, on Debian usually '109'
readonly tor_uid="109"

# Tor TransPort
readonly trans_port="9040"

# Tor DNSPort
readonly dns_port="5353"

# Tor VirtualAddrNetworkIPv4
readonly virtual_addr_net="10.192.0.0/10"

# LAN destinations that shouldn't be routed through Tor
readonly non_tor="127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
## End of Network settings

checkroot() {
    if [[ "$(id -u)" -ne 0 ]]; then
	printf "Please, run as root!\n"
	exit 1
    fi
}

checkprocess() {

checktorprocess=$(pidof tor > /dev/null; echo $?)
if [[ $checktorprocess == 0 ]]; then
kill -2 $(pidof tor)
tor > /dev/null 2>&1 &
sleep 10
else
tor > /dev/null 2>&1 &
sleep 10
fi


}

checktor() {

checktorprocess=$(pidof tor > /dev/null; echo $?)
if [[ $checktorprocess == 0 ]]; then
printf "\e[1;92m[*] Tor is running!\e[0m\n"
else
printf "\e[1;92m[*] Starting Tor\e[0m\n"
tor > /dev/null 2>&1 &
sleep 10
fi


}

iptor() {

ip=$(curl -s --socks5-hostname localhost:9050 dnsleak.com | grep -o 'address:.*' | cut -d '<' -f1 | cut -d " " -f2)
printf "\n\e[1;92m[*] Your Tor IP is:\e[0m\e[1;77m %s\e[0m\n" $ip

}

start() {
    checkroot
    # check program is already running
    check1=$(iptables -L | grep -o "owner")
    if [[ $check1 == "owner" ]]; then
    printf "\e[1;92m[!] Anonymous Surf is already running! \e[0m\e[1;77m Use --stop to stop\e[0m\n"
    exit 1
    fi
    # check torrc config file 
    check=$(grep VirtualAddrNetworkIPv4 /etc/tor/torrc)
    if [[ $check == "" ]]; then
    printf "VirtualAddrNetworkIPv4 10.192.0.0/10\nAutomapHostsOnResolve 1\nTransPort 9040\nSocksPort 9050\nDNSPort 5353\n" >> /etc/tor/torrc
    printf "\e[1;92m[*] Configured /etc/tor/torrc \e[0m\e[1;77m Restarting Tor...\e[0m\n"
    checkprocess #exit 1
    fi    
    # save current iptables rules
    checktor
    printf "\e[1;77m[*] Backup iptables rules... \e[0m"

    if ! iptables-save > "iptables.backup"; then
        printf "\n\e[1;93m[ failed ] can't copy iptables rules. Run as root!\e[0m\n"
        exit 1
    fi

    printf "\e[1;92mDone\e[0m\n"
   
    # flush current iptables rules
    printf "\e[1;77m[*] Flush iptables rules... "
    iptables -F
    iptables -t nat -F
    printf "\e[1;92mDone\n"

    # configure system's DNS resolver to use Tor's DNSPort on the loopback interface
    # i.e. write nameserver 127.0.0.1 to 'etc/resolv.conf' file
    printf "\e[1;77m[*] Configuring system's DNS resolver to use Tor's DNSPort\e[0m\n"

    if ! cp -vf /etc/resolv.conf "/etc/resolv.conf.backup"; then
        printf "\n\e[1;93m[ failed !] can't copy resolv.conf. Run as root!\e[0m\n"
        exit 1
    fi

    printf "nameserver 127.0.0.1" > /etc/resolv.conf
    

    # write new iptables rules
    printf "\e[1;77m[*] Set new iptables rules... "

    #-------------------------------------------------------------------------
    # set iptables *nat
    iptables -t nat -A OUTPUT -m owner --uid-owner $tor_uid -j RETURN
    iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $dns_port
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j REDIRECT --to-ports $dns_port
    iptables -t nat -A OUTPUT -p udp -m owner --uid-owner $tor_uid -m udp --dport 53 -j REDIRECT --to-ports $dns_port

    iptables -t nat -A OUTPUT -p tcp -d $virtual_addr_net -j REDIRECT --to-ports $trans_port
    iptables -t nat -A OUTPUT -p udp -d $virtual_addr_net -j REDIRECT --to-ports $trans_port

    # allow clearnet access for hosts in $non_tor
    for clearnet in $non_tor 127.0.0.0/9 127.128.0.0/10; do
        iptables -t nat -A OUTPUT -d "$clearnet" -j RETURN
    done

    # redirect all other output to Tor TransPort
    iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $trans_port
    iptables -t nat -A OUTPUT -p udp -j REDIRECT --to-ports $trans_port
    iptables -t nat -A OUTPUT -p icmp -j REDIRECT --to-ports $trans_port

    # set iptables *filter
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    # allow clearnet access for hosts in $non_tor
    for clearnet in $non_tor 127.0.0.0/8; do
        iptables -A OUTPUT -d "$clearnet" -j ACCEPT
    done

    # allow only Tor output
    iptables -A OUTPUT -m owner --uid-owner $tor_uid -j ACCEPT
    iptables -A OUTPUT -j REJECT
    #-------------------------------------------------------------------------
    ## End of iptables settings

     printf "\e[1;92mDone\e[0m\n"

     printf  "\e[1;92m[ System under Tor! ]\e[0m\n"
     iptor
}

## Stop transparent proxy
stop() {
    checkroot
    printf "\e[1;77m[*] Stopping Transparent Proxy\e[0m\n"

    ## Resets default settings
    # flush current iptables rules
    printf "\e[1;77m[*] Flush iptables rules... \e[0m"
    iptables -F
    iptables -t nat -F
    printf "\e[1;92mDone\e[0m\n"

    # restore iptables
    printf "\e[1;77m[*] Restore the default iptables rules... \e[0m"

    iptables-restore < "iptables.backup"
    printf "\e[1;92mDone\n"

    # restore /etc/resolv.conf --> default nameserver
    printf "\e[1;92m[*] Restore /etc/resolv.conf file with default DNS\e[0m\n"
    rm -v /etc/resolv.conf
    cp -vf "/etc/resolv.conf.backup" /etc/resolv.conf
  
    ## End
    printf "\e[1;77m[*] Transparent Proxy stopped\e[0m\n"
}

status() {

    check1=$(iptables -L | grep -o "owner")
    if [[ $check1 == "owner" ]]; then
    printf "\e[1;92m[*] Anonymous Surf is running! \e[0m\n"
    iptor
    exit 1
    else
    printf "\e[1;93m[!] Anonymous Surf is NOT running! \e[0m\n"
    exit 1
    fi



}


case "$1" in --start) start ;; --stop) stop ;; --status) status ;; *)
     printf "\e[1;92mUsage:\e[0m\e[1;77m ./debiantor.sh --start / --stop\e[0m\n"
     exit 1
esac
