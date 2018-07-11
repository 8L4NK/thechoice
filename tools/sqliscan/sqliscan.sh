#!/bin/bash
# SqliScan v1.0
# Coded by: thelinuxchoice
# Instagram: @thelinuxchoice
# https://github.com/thelinuxchoice/sqliscan

banner() {
printf "\n"
printf "\e[1;91m███████╗ ██████╗ ██╗     ██╗\e[0m\e[1;92m███████╗ ██████╗ █████╗ ███╗   ██╗\e[0m \n"
printf "\e[1;91m██╔════╝██╔═══██╗██║     ██║\e[0m\e[1;92m██╔════╝██╔════╝██╔══██╗████╗  ██║\e[0m \n"
printf "\e[1;91m███████╗██║   ██║██║     ██║\e[0m\e[1;92m███████╗██║     ███████║██╔██╗ ██║\e[0m \n"
printf "\e[1;91m╚════██║██║▄▄ ██║██║     ██║\e[0m\e[1;92m╚════██║██║     ██╔══██║██║╚██╗██║\e[0m \n"
printf "\e[1;91m███████║╚██████╔╝███████╗██║\e[0m\e[1;92m███████║╚██████╗██║  ██║██║ ╚████║\e[0m \n"
printf "\e[1;91m╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝\e[0m\e[1;92m╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝\e[0m \n"
printf "\n"
printf "      \e[1;93m.::.\e[0m\e[1;77m SqliScan v1.0 Coded by @thelinuxchoice \e[0m\e[1;93m.::.\e[0m\n"
printf "\n"
}
checksqli() {

for url in $(cat saved.txt); do

printf "\e[1;93mScanning:\e[0m\e[77m %s\e[0m\n" $url
checkurl=$(curl -s "$url" | grep -o 'SQL syntax\|mysql_fetch_assoc\|mysql_fetch_array\|mysql_num_rows\|is_writable\|mysql_result\|pg_exec\|mysql_query\|pg_query\|System Error\|io_error\|privilege_not_granted\|getimagesize\|preg_match\|DB Error'; echo $?)
if [[ $checkurk == 0 ]]; then
printf "\e[1;92m [*] Possible Vulnerable target:\e[1;77m %s\ne[0m" $url
fi
done


}

#banner

page=0
#domains=(ac ad ae af ag ai al am an ao aq ar as at au aw ax az ba bb bd be bf bg bh bi bj bm bn bo br bs bt bv bw by bz ca cc cd cf cg ch ci ck cl cm cn co cr cu cv cx cv cz de dj dk dm do dz ec ee eg eh er es et eu fi fj fk fm fo fr ga gb gd ge gf gg gh )
read -p $'\e[1;92m[*] Dork: \e[0m' dork
printf "\e[1;92m[*] Searching targets, please wait...\e[0m\n"

pages=100
while [[ $page -lt $pages ]]; do
#for domain in ${domains[@]}; do
curl -s 'https://www.bing.com/search?q='$dork'&first='$page'&FORM=PORE' >> file1
let page+=10
#done
done
grep -o 'href="http[^"]*"' file1 > file2
sed -i '/microsoft/d' ./file2
sed -i '/wordpress/d' ./file2
sed -i '/bing/d' ./file2
cat file2 | sort | uniq | cut -d "\"" -f2 | tr -d '\"' > saved.txt
printf "\e[1;92m[*] Results:\n\e[0m\e[1;77m"
cat saved.txt
printf "\e[0m\n"
printf "\e[1;92m[*] Saved:\e[0m\e[1;77m saved.txt\e[0m\n"

rm -rf file*
default_search="Y"
read -p $'\e[1;92m[*] Search DB Errors on targets? \e[0m\e[1;77m[Y/n]\e[0m' search
search="${search:-${default_search}}"
if [[ $search == "y" || $search == "Y" || $search == "Yes" || $search == "yes" ]]; then
checksqli
else
exit 1
fi
