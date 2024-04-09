# SOC-Checker
#
# The SOC-Checker script is a bash script provides functionalities for LAN scanning and launching attacks on the network in order to check the SOC team or the configuration of the systems.
#
# Features
# Network Scanning with nmap: Conducts an nmap scan on the LAN to gather information about hosts and services.
# Brute Force Attack: Allows the user to choose a service (SSH, FTP, Telnet, SMB) to attack and performs a brute force attack using Hydra against the chosen service.
# Denial of Service (DoS) Attack: Offers three types of DoS attacks: ICMP flood, SYN flood, and UDP flood and executes the selected DoS attack using hping3.
# Man-in-the-Middle (MITM) Attack: Prompts the user to input the network interface and gateway IP for the attack and executes an ARP spoofing attack using arpspoof
#
# Installation
# git clone https://github.com/LirayS/SOC-Checker.git
# cd SOC-Checker
# chmod +x SOC-Checker.sh
# sudo ./SOC-Checker.sh
#
# Disclaimer
# This script is intended for forensic analysis and informational purposes only. The author and contributors of this script are not responsible for any misuse or illegal activities conducted using this tool.