#!/bin/bash

#This script will help you perform an anonymous attack using tor, kalitorify, and ssh
#In order for the script to work well please enter as sudo first=

# Checking if the current user is sudo
if [[ $(id -u) -ne 0 ]]; then
  echo "This script requires sudo privileges. Please run it with sudo."
  exit 1
fi

#checking if figlet is installed
    if ! command -v figlet &> /dev/null; then
        sudo apt update > /dev/null
        sudo apt install -y figlet > /dev/null

    fi

figlet "SSH HELPER TOOL"

#Checking if curl is installed
function curl_check() {
    if ! command -v curl &> /dev/null; then
        echo "curl is not installed. Installing..."
        sudo apt update > /dev/null
        sudo apt install -y curl > /dev/null
	echo "curl has been installed"
    fi
}

#checking if geoiplookup is installed
function geoiplookup_check() {
    if ! command -v geoiplookup &> /dev/null; then
        echo "geoiplookup is not installed. Installing..."
        sudo apt update > /dev/null
        sudo apt install -y geoip-bin > /dev/null
   	echo "geoiplookup has been installed"

    fi
}

#Checking if ssh command is installed
function ssh_check() {
    if ! command -v ssh &> /dev/null; then
        echo "ssh is not installed. Installing..."
        sudo apt update > /dev/null
        sudo apt install -y ssh > /dev/null
	echo "ssh has been installed"

    fi
}

#Checking if nmap is installed
function nmap_check() {
  if ! command -v nmap &>/dev/null; then
         echo "nmap is not installed. Installing..."
         sudo apt update >/dev/null
	 sudo apt install -y nmap >/dev/null
	 echo "nmap has been installed"

  fi
}

# Checking if whois is installed
function whois_check() {
  if ! command -v whois &>/dev/null; then
    echo "whois is not installed. Installing..."
    sudo apt update >/dev/null
    sudo apt install -y whois >/dev/null
    echo "whois has been installed"

  fi
}

# Checking and installing dependencies
curl_check
geoiplookup_check
ssh_check
nmap_check
whois_check

# Get external IP and geolocation
IP=$(curl -sS https://check.torproject.org/api/ip | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
geolocation=$(geoiplookup $IP | cut -d ":" -f2)
echo "#Your current IP address is $IP and your geolocation is $geolocation"

sleep 3

# Checking if Tor and Kalitorify are installed
function services() {
    if [[ -d "/usr/share/kalitorify" && $(command -v tor) ]]; then
        echo "#Tor and Kalitorify are installed"
        kalitorify -t > /dev/null 2>&1
        echo "#KALITORIFY IS ON"
    else
        git clone https://github.com/brainfucksec/kalitorify
        sudo apt install -y tor >/dev/null 2>&1
        # Starting the services
        # Silencing the kalitorify into a file
        kalitorify -t > /dev/null 2>&1
        echo "#Kalitorify is on"
    fi
}

services
sleep 3

# Checking IP and geolocation again after turning on Tor
spoofed_IP=$(curl -sS https://check.torproject.org/api/ip | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
spoofed_geolocation=$(geoiplookup $spoofed_IP | cut -d ":" -f2)

echo "#Your current IP address is $spoofed_IP"

function check_anonymous() {
    if [[ $geolocation == $spoofed_geolocation ]]; then
        echo "***CAUTION!!! You are not anonymous!!!***"
        exit
    else
        echo "#YOU ARE ANONYMOUS! Welcome to $spoofed_geolocation ;) "
    fi
}

check_anonymous

# Getting information from the user for establishing SSH connection
function connect_target() {
    read -p "Please enter target's IP:" target
    read -p "Please enter desired port:" port
    read -p "Please enter target's username:" user
    read -p "Please enter username's passworrd:" pass

    # Getting the target's info - IP, country, geolocation, whois, port scan using nmap:
    sshpass -p "$pass" ssh  -T -o StrictHostKeyChecking=no -p "$port" "$user@$target"  << EOF > sshpass_log
    # Checking for tools on target    
    curl_check  ; whois_check ; nmap_check ; geoiplookup_check
    echo "$(date) - Remote Server Details:"
    echo 'IP: ' && target_IP=$(curl -sS ifconfig.me/ip) && echo "$target_IP"
    echo 'Country: ' && geoip=$(geoiplookup "$target_IP") && echo "$geoip"
    echo 'Uptime: ' && uptime

    echo "$(date) - Whois Lookup:"
    whois "$target"

    echo "$(date) - Port Scan:"
    nmap -sV "$target"
  
EOF

    sleep 3

    echo "#INFORMATION SUCCESSFULLY SAVED INTO: ssh_log.txt"
}

connect_target

sleep 3

# Turning off Kalitorify
kalitorify --clearnet > /dev/null 2>&1
echo "#Kalitorify is off"

figlet "GOODBYE"

cat ssh_log.txt
