#!/bin/bash

# Scanning the activity from the results using nmap, geoiplookup, whois:

# Obtain external IP address
external_ip=$(curl -s ifconfig.me)
echo "External IP address: $external_ip"

# Obtain internal IP address from the latest line of alerter.txt
ip=$(cat alerter.txt | tail -n 1 | grep -s -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
geoloc=$(geoiplookup $external_ip)
info=$(whois $external_ip)

echo -e "Caught $ip" >> busted.txt 
echo "$external_ip geolocation is $geoloc" >> busted.txt
echo "WHOIS info:"
echo "$info" >> busted.txt

# Scanning using nmap
nmap -p- -sV -Pn -O $ip >> busted.txt

cat busted.txt