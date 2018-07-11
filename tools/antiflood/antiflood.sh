#!/bin/bash
# coded by @thelinuxchoice (Instagram)

banner() {

printf "\e[1;97m"
printf "  ____  ____   ______  ____  _____  _       ___    ___   ___   \n"
printf " /    T|    \ |      Tl    j|     || T     /   \  /   \ |   \  \n"
printf "Y  o  ||  _  Y|      | |  T |   __j| |    Y     YY     Y|    \ \n"
printf "|     ||  |  |l_j  l_j |  | |  l_  | l___ |  O  ||  O  ||  D  Y\n"
printf "|  _  ||  |  |  |  |   |  | |    | |     T|     ||     ||     |\n"
printf "|  |  ||  |  |  |  |   j  l |  T   |     |l     !l     !|     |\n"
printf "l__j__jl__j__j  l__j  |____jl__j   l_____j \___/  \___/ l_____j\n"
printf "\n\e[0m"                                                               
printf "\e[101m::\e[1;77m Protection against: DoS, DDoS, UDP/TCP Flood, BruteForcer ::\e[0m\n\n"


}


checkbrute=$(/sbin/iptables -L | /bin/grep -o "antibrute" > /dev/null;echo "$?") >&2
checkicmp=$(/sbin/iptables -t mangle -L | /bin/grep -o "icmp" > /dev/null; echo "$?") >&2
checkudp=$(/sbin/iptables -L | /bin/grep -o "udp" > /dev/null; echo "$?") >&2
checkfragchains=$(/sbin/iptables -t mangle -L | /bin/grep -o "\-f" > /dev/null; echo "$?") >&2
checksourceip=$(/sbin/iptables -L | /bin/grep -o "111" > /dev/null;echo "$?") >&2
checkrst=$(/sbin/iptables -L | /bin/grep -o "RST" > /dev/null;echo "$?") >&2
checkinvalid=$(/sbin/iptables -t mangle -L | /bin/grep -o "INVALID" > /dev/null; echo "$?") >&2
checknew=$(/sbin/iptables -t mangle -L | /bin/grep -o "\!FIN" > /dev/null; echo "$?") >&2
checkmss=$(/sbin/iptables -t mangle -L | /bin/grep -o "mss" > /dev/null; echo "$?") >&2
checksourcesec=$(/sbin/iptables -L | /bin/grep -w "60/sec burst 20" > /dev/null; echo "$?") >&2
checkbogus=$(/sbin/iptables -t mangle -L | /bin/grep -o "URG" > /dev/null; echo "$?") >&2
checkspoof=$(/sbin/iptables -t mangle -L | /bin/grep -o "224.0.0.0/3" > /dev/null; echo "$?") >&2

checkroot() {
    if [[ "$(id -u)" -ne 0 ]]; then
      printf ".:: Please, run this program as root!\n"
      exit 1
    fi
}
readconfig() {

    if [ ! -f "/etc/antiflood.cfg" ]; then
        printf "\e[1;77m:: Creating Anti Flood config file (/etc/antiflood.cfg)... \e[0m"
        /usr/bin/touch /etc/antiflood.cfg
        printf "antibrute=y\n" >> /etc/antiflood.cfg
        printf "ports=21,22,23,25,110,143,443\n" >> /etc/antiflood.cfg
        printf "seconds=60\n" >> /etc/antiflood.cfg
        printf "hitcount=6\n" >> /etc/antiflood.cfg
        printf "udpflood=y\n" >> /etc/antiflood.cfg
        printf "icmp=y\n" >> /etc/antiflood.cfg
        printf "chains=y\n" >> /etc/antiflood.cfg
        printf "sourceip=y\n" >> /etc/antiflood.cfg
        printf "rst=y\n" >> /etc/antiflood.cfg
        printf "invalid=y\n" >> /etc/antiflood.cfg
        printf "new=y\n" >> /etc/antiflood.cfg
        printf "mss=y\n" >> /etc/antiflood.cfg
        printf "sourceipsec=y\n" >> /etc/antiflood.cfg
        printf "bogus=y\n" >> /etc/antiflood.cfg   
        printf "spoof=n\n" >> /etc/antiflood.cfg
     printf "\e[1;92mDone\e[0m\n"
    fi
}
start() {
#banner
checkroot
readconfig
source /etc/antiflood.cfg

       
       #Anti Brute Force

            if [[ "$antibrute" == "y" || "$antibrute" == "yes" || "$antibrute" == "Y" ]] && [[ "$checkbrute" == "1" ]]; then

       /sbin/iptables -A INPUT -p tcp -m multiport --dports $ports -m conntrack --ctstate NEW -m recent --set --name antibrute
       /sbin/iptables -A INPUT -p tcp -m multiport --dports $ports -m conntrack --ctstate NEW -m recent --update --seconds $seconds --hitcount $hitcount -j DROP --name antibrute
            fi

           
       #Anti UDP flood

            if [[ "$udpflood" == "y" || "$udpflood" == "yes" || "$udpflood" == "Y" ]] && [[ "$checkudp" == "1" ]]; then
       /sbin/iptables -N udpflood
       /sbin/iptables -A INPUT -p udp -j udpflood
       /sbin/iptables -A udpflood -p udp -m limit --limit 50/s -j RETURN
       /sbin/iptables -A udpflood -j DROP

            fi


       #drop icmp
            if [[ "$icmp" == "y" || "$icmp" == "yes" || "$icmp" == "Y"  ]] && [[ "$checkicmp" == "1" ]]; then
       /sbin/iptables -t mangle -A PREROUTING -p icmp -j DROP
            fi
       #drop fragments in all chains
            if [[ "$chains" == "y" || "$" == "yes" || "$" == "Y" ]] && [[ "$checkfragchains" == "1" ]]; then
       /sbin/iptables -t mangle -A PREROUTING -f -j DROP
            fi
       #limit connections per source ip
            if [[ "$sourceip" == "y" || "$sourceip" == "yes" || "$sourceip" == "Y" ]] && [[ "$checksourceip" == "1" ]]; then
       /sbin/iptables -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset
            fi
       #limit RST packets
            if [[ "$rst" == "y" || "$rst" == "yes" || "$rst" == "Y" ]] && [[ "$checkrst" == "1" ]]; then
       /sbin/iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
       /sbin/iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
            fi
       #drop invalid packets
            if [[ "$invalid" == "y" || "$invalid" == "yes" || "$invalid" == "Y" ]] && [[ "$checkinvalid" == "1" ]]; then
       /sbin/iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
            fi
       #drop tcp packets that are new and are not SYN
            if [[ "$new" == "y" || "$new" == "yes" || "$new" == "Y" ]] && [[ "$checknew" == "1" ]]; then
       /sbin/iptables -t mangle -A PREROUTING  -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
            fi
       #drop SYN packets with suspicios MSS value
            if [[ "$mss" == "y" || "$mss" == "yes" || "$mss" == "Y" ]] && [[ "$checkmss" == "1" ]]; then
       /sbin/iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
            fi
       #limit new TCP connections per second per source IP
            if [[ "$sourceipsec" == "y" || "$sourceipsec" == "yes" || "$sourceipsec" == "Y" ]] && [[ "$checksourcesec" == "1" ]]; then
       /sbin/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
       /sbin/iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
            fi
       # Block packets with bogus TCP flags ### 
            if [[ "$bogus" == "y" || "$bogus" == "yes" || "$bogus" == "Y" ]] && [[ "$checkbogus" == "1" ]]; then
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
           fi  
       # Block spoofed packets ### 
          if [[ "$spoof" == "y" || "$spoof" == "yes" || "$spoof" == "Y" ]] && [[ "$checkspoof" == "1" ]]; then
       /sbin/iptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP 
       /sbin/iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP  
          fi
       printf "\e[1;32m\n:: Config file (/etc/antiflood.cfg):\e[0m\n"
       source /etc/antiflood.cfg
       printf "\e[1;77m"
       printf "Drop icmp: %s\n" $icmp
       printf "Anti UDP Flood: %s\n" $udpflood
       printf "Drop fragments in all chains: %s\n" $chains 
       printf "Limit connections per source ip: %s\n" $sourceip
       printf "Limit RST packets: %s\n" $rst
       printf "Drop invalid packets: %s\n" $invalid
       printf "Drop tcp packets that are new and are not SYN: %s\n" $new
       printf "Drop SYN packets with suspicios MSS value: %s\n" $mss
       printf "Limit new TCP connections per second per source IP: %s\n" $sourceipsec
       printf "Block packets with bogus TCP flags: %s\n" $bogus
       printf "Block spoofed packets: %s\n" $spoof
       printf "Anti-BruteForce: %s\n" $antibrute
       printf "\e[0m"
       if [[ "$antibrute" == "y" || "$antibrute" == "Y" || "$antibrute" == "yes" ]]; then
       printf "Port(s): $ports\n"
       printf "Seconds: $seconds\n"
       printf "Hitcount: $hitcount\n"
       fi
       printf "\n"
printf "\e[1;92mStatus:\e[0m\e[1;77m sudo ./antiflood.sh --status\e[0m\n"
printf "\e[1;92mStop:\e[0m\e[1;77m sudo ./antiflood.sh --stop\e[0m\n"
printf "\e[1;92mConfig:\e[0m\e[1;77m sudo ./antiflood.sh --config\e[0m\n"

}

status() {
checkroot
banner
source /etc/antiflood.cfg
printf "\e[1;92m[*] Running: \e[0m\n"

if [[ "$checkicmp" == "0" ]]; then
printf "\e[1;77m:: Drop icmp (ping request) \n\e[0m"
fi

if [[ "$checkudp" == "0" ]]; then
printf "\e[1;77m:: Anti UDP Flood\e[0m\n"
fi

if [[ "$checkfragchains" == "0" ]]; then
printf "\e[1;77m:: Drop fragments in all chains\e[0m\n"
fi

if [[ "$checksourceip" == "0" ]]; then
printf "\e[1;77m:: Limit connections per source ip\e[0m\n"
fi

if [[ "$checkrst" == "0" ]]; then
printf "\e[1;77m:: Limit RST packets\n\e[0m"
fi

if [[ "$checkinvalid" == "0" ]]; then
printf "\e[1;77m:: Drop invalid packets\n\e[0m"
fi

if [[ "$checknew" == "0" ]]; then
printf "\e[1;77m:: Drop tcp packets that are new and are not SYN\n\e[0m"
fi

if [[ "$checkmss" == "0" ]]; then
printf "\e[1;77m:: Drop SYN packets with suspicios MSS value\n\e[0m"
fi

if [[ "$checksourcesec" == "0" ]]; then
printf "\e[1;77m:: Limit new TCP connections per second per source IP\n\e[0m"
fi

if [[ "$checkbogus" == "0" ]]; then
printf "\e[1;77m:: Block packets with bogus TCP flags\n\e[0m"
fi

if [[ "$checspoof" == "0" ]]; then
printf "\e[1;77m:: Block spoofed packets\n\e[0m"
fi


if [[ "$checkbrute" == "0" ]]; then
printf "\e[1;77m:: Anti Brute Force, Ports: %s, Seconds: %s, Hitcount: %s\n\e[0m" $ports $seconds $hitcount
fi


}


stop() {
checkroot
source /etc/antiflood.cfg


  # antibrute force
            if  [[ "$checkbrute" == "0" ]]; then
       /sbin/iptables -D INPUT -p tcp -m multiport --dports $ports -m conntrack --ctstate NEW -m recent --set --name antibrute
       /sbin/iptables -D INPUT -p tcp -m multiport --dports $ports -m conntrack --ctstate NEW -m recent --update --seconds $seconds --hitcount $hitcount -j DROP --name antibrute
            fi

  #udpflood
            if [[ "$checkudp" == "0" ]]; then
       /sbin/iptables -D INPUT -p udp -j udpflood
       /sbin/iptables -D udpflood -p udp -m limit --limit 50/s -j RETURN
       /sbin/iptables -D udpflood -j DROP
       /sbin/iptables -X udpflood
            fi

  #icmp
            if [[ "$checkicmp" == "0" ]]; then
       /sbin/iptables -t mangle -D PREROUTING -p icmp -j DROP
            fi

  #drop fragments in all chains
            if  [[ "$checkfragchains" == "0" ]]; then
       /sbin/iptables -t mangle -D PREROUTING -f -j DROP
            fi

  #limit connections per source ip
            if  [[ "$checksourceip" == "0" ]]; then
       /sbin/iptables -D INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset
            fi

  #limit RST packets
            if [[ "$checkrst" == "0" ]]; then
       /sbin/iptables -D INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
       /sbin/iptables -D INPUT -p tcp --tcp-flags RST RST -j DROP
            fi

  #drop invalid packets
            if [[ "$checkinvalid" == "0" ]]; then
       /sbin/iptables -t mangle -D PREROUTING -m conntrack --ctstate INVALID -j DROP
            fi

  #drop tcp packets that are new and are not SYN
            if [[ "$checknew" == "0" ]]; then
       /sbin/iptables -t mangle -D PREROUTING  -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
            fi

  #drop SYN packets with suspicios MSS value
            if [[ "$checkmss" == "0" ]]; then
       /sbin/iptables -t mangle -D PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
            fi

  #limit new TCP connections per second per source IP
            if [[ "$checksourcesec" == "0" ]]; then
       /sbin/iptables -D INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
       /sbin/iptables -D INPUT -p tcp -m conntrack --ctstate NEW -j DROP
            fi

  # Block packets with bogus TCP flags  
            if [[ "$checkbogus" == "0" ]]; then
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP  
           fi
 
  # Block Spoofed packets
          if [[ "$checkspoof" == "0" ]]; then
       /sbin/iptables -t mangle -D PREROUTING -s 224.0.0.0/3 -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -s 169.254.0.0/16 -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -s 172.16.0.0/12 -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -s 192.0.2.0/24 -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -s 192.168.0.0/16 -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -s 10.0.0.0/8 -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -s 0.0.0.0/8 -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -s 240.0.0.0/5 -j DROP 
       /sbin/iptables -t mangle -D PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP  
          fi

 printf "\e[1;92m:: All running rules stopped\e[0m\n"

}

config() {
checkroot
stop > /dev/null

    if [ ! -f "/etc/antiflood.cfg" ]; then
       /usr/bin/touch /etc/antiflood.cfg
    fi

default_ports="21,22,23,25,110,143,443"
default_seconds="60"
default_hitcount="6"
default_antib="y"
read -p $'\e[1;77mEnable Anti Brute Force? [Y/n]\e[0m:' antib
antib="${antib:-${default_antib}}"
if [[ "$antib" == "y" || "$antib" == "Y" || "$antib" == "yes" ]]; then
read -e -p $'\e[1;77mAnti-BruteForce Port(s) (Default: 21,22,23,25,110,143,443): \e[0m' p
p="${p:-${default_ports}}"
read -e -p $'\e[1;77mAnti-BruteForce Seconds (Default: 60): \e[0m' s
s="${s:-${default_seconds}}"
read -e -p $'\e[1;77mAnti-BruteForce Hitcount (Default: 6): \e[0m' h
h="${h:-${default_hitcount}}"
fi
printf "antibrute=$antib\n" > /etc/antiflood.cfg
printf "ports=$p\n" >> /etc/antiflood.cfg
printf "seconds=$s\n" >> /etc/antiflood.cfg
printf "hitcount=$h\n" >> /etc/antiflood.cfg
default_ricmp="y"

# icmp
read -p $'\e[1;77mBlock icmp (ping) request [Y/n]: \e[0m' ricmp
ricmp="${ricmp:-${default_ricmp}}"
printf "icmp=$ricmp\n" >> /etc/antiflood.cfg


# udp
default_rudpflood="y"
read -p $'\e[1;77mAnti UDP Flood [Y/n]: \e[0m' rudpflood
rudpflood="${rudpflood:-${default_rudpflood}}"
printf "udpflood=$rudpflood\n" >> /etc/antiflood.cfg


# chains
default_rchains="y"
read -p $'\e[1;77mDrop fragments in all chains [Y/n]: \e[0m' rchains
#="${:-${default_}}"
rchains="${rchains:-${default_rchains}}"
printf "chains=$rchains\n" >> /etc/antiflood.cfg


# per source
#read -p " [Y/n]: " 
default_rsource="y"
read -p $'\e[1;77mLimit connections per source ip [Y/n]: \e[0m' rsource
rsource="${rsource:-${default_rsource}}"
printf "sourceip=$rsource\n" >> /etc/antiflood.cfg


# rst
default_rrst="y"
read -p $'\e[1;77mLimit RST packets [Y/n]: \e[0m' rrst
rrst="${rrst:-${default_rrst}}"
printf "rst=$rrst\n" >> /etc/antiflood.cfg


# drop invalid packets
default_rinvalid="y"
read -p $'\e[1;77mDrop invalid packets [Y/n]: \e[0m' rinvalid
rinvalid="${rinvalid:-${default_rinvalid}}"
printf "invalid=$rinvalid\n" >> /etc/antiflood.cfg


# drop tcp packets that are new and are not SYN
# ="${:-${default_}}"
default_rnew="y"
read -p $'\e[1;77mDrop tcp packets that are new and are not SYN [Y/n]: \e[0m' rnew
rnew="${rnew:-${default_rnew}}"
printf "new=$rnew\n" >> /etc/antiflood.cfg


# drop SYN packets with suspicios MSS value
default_rmss="y"
read -p $'\e[1;77mDrop SYN packets with suspicios MSS value [Y/n]: \e[0m' rmss
rmss="${rmss:-${default_rmss}}"
printf "mss=$rmss\n" >> /etc/antiflood.cfg


# limit new TCP connections per second per source IP
default_rsourcesec="y"
read -p $'\e[1;77mLimit new TCP connections per second per source IP [Y/n]: \e[0m' rsourcesec
rsourcesec="${rsourcesec:-${default_rsourcesec}}"
printf "sourceipsec=$rsourcesec\n" >> /etc/antiflood.cfg


# Block packets with bogus TCP flags
default_rbogus="y"
read -p $'\e[1;77mBlock packets with bogus TCP flags [Y/n]: \e[0m' rbogus
rbogus="${rbogus:-${default_rbogus}}"
printf "bogus=$rbogus\n" >> /etc/antiflood.cfg


# Block spoofed packets
default_rspoof="y"
read -p $'\e[1;77mBlock spoofed packets [Y/n]: \e[0m' rspoof
rspoof="${rspoof:-${default_rspoof}}"
printf "spoof=$rspoof\n" >> /etc/antiflood.cfg

start
}
case "$1" in --start) start ;; --stop) stop ;; --config) config ;; --status) status ;;  *)
   banner 
   checkroot
   printf "\e[1;77m:: Usage: sudo ./antiflood --start --stop --status --config\n"
    exit 1
esac
