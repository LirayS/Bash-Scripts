#!/bin/bash

# This script will create a honeypot service for the user to choose and automatically operate.
# This is the first part that creates the honeypot, the other parts alert and scan results.
# Created by Liray Spilberg
# Hmagen773616
# Lecturer - Eliran Berkovich

# Make sure to run the script with sudo privileges

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset text formatting

# Checking if the current user is sudo
if [[ $(id -u) -ne 0 ]]; then
  echo -e "${RED}This script requires sudo privileges. Please run it with sudo.${RESET}"
  exit 1
fi

echo -e "${RED}WELCOME TO THE HONEYPOT HELPER TOOL ${RESET}"
echo -e "${BLUE}This script will create a honeypot using msfconsole. If you wish to be alerted on activity related to the honeypot, please run ${RED}alerter_script${RESET} as well. Scanning results are also a possibility using ${RED}scanner_script${RESET}. ENJOY :)"

# Letting the user choose which service they would like to use a honeypot on:
while true; do
  echo -e "${BLUE}[+]${RESET} Please choose the number of the service you would like to activate the honeypot on:" 
  read -p "
  1. FTP
  2. SMB
  3. Telnet 
  4. All services
  Enter answer here:" answer

  case $answer in
    1)
      echo -e "${BLUE}Activating honeypot on FTP service...${RESET}"
      msfconsole -q -x "resource ftp.rc" >> alerter.txt
      break
      ;;
    2)
      echo -e "${BLUE}Activating honeypot on SMB service...${RESET}"
      msfconsole -q -x "resource smb.rc" >> alerter.txt
      break
      ;;
    3)
      echo -e "${BLUE}Activating honeypot on Telnet service...${RESET}"
      msfconsole -q -x "resource telnet.rc" >> alerter.txt
      break
      ;;
    4)
      echo -e "${BLUE}Activating honeypot on all services...${RESET}"
      msfconsole -q -x "resource all_services.rc" >> alerter.txt
      break
      ;;
    *)
      echo -e "${RED}Invalid option. Please choose a number between 1 and 4 ${RESET}"
      ;;
  esac
done
