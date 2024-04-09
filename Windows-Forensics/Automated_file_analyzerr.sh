#!/bin/bash

# This script will help you analyze memory and HDD files using carving tools and volatility
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
if [[ $(id -u) -ne 0 ]]; 
    then
        echo "This script requires sudo privileges. Please run it with sudo."
        exit 1
fi


echo "
            ______              
         .-'      \`-.           
       .'            \`.         
      /                \\        
     ;                 ;\`       
     |                 | ;       
     ;                 ; |
     '\               /  ;       
      \`.           . ' /        
       \`.-._____.-'  .'         
         / /\`_____.-'           
        / / /                   
       / / /
      / / /
     / / /
    / / /
   / / /
  / / /
 / / /
/ / /
\/_/
"

# Create a directory to store analysis results
analysis_dir="automated_analyzer_results"
mkdir -p "$analysis_dir"

# Define the report file
report_file="$analysis_dir/report.txt"
echo -e "${BLUE}Analysis completed on: $(date)" >> "$report_file"

# Function to count the number of files in a directory
count_files() {
    local dir="$1"
    local file_count=$(find "$dir" -type f | wc -l)
    echo "$file_count" 
}


 
# Memory function:
analyze_memory() {

    echo -e "${BLUE}[+]:${RESET}File type: Memory" | tee -a "$report_file"
  
    # Checking if volatility exits and if not, installing it
    vol_check() {
        if [ ! -d "volatility_2.6_lin64_standalone" ]; 
            then
                echo -e "${BLUE}[+]:${RESET}Volatility can't be found in the directory, installing ..."
                wget http://downloads.volatilityfoundation.org/releases/2.6/volatility_2.6_lin64_standalone.zip >/dev/null 2>&1
                unzip volatility_2.6_lin64_standalone.zip >/dev/null 2>&1
                echo -e "${BLUE}[+]:${RESET}Volatility 2.6 for Linux has been installed" | tee -a "$report_file"
     
        fi
    }

    vol_check
    
    sleep 2
        
    # Run Volatility and capture the output
    volatility_output=$(./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f $file_path imageinfo)

    sleep 2

    # Extract the line with the suggested profile(s)
    suggested_profile_line=$(echo "$volatility_output" | grep -o 'Suggested Profile(s) : [^$]*')  

    sleep 2

    # Extract the suggested profile name from the line
    suggested_profile=$(echo "$suggested_profile_line" | cut -d ":" -f2 | cut -d "," -f1 | sed 's/ //g') 

    sleep 2

    # Check if a suggested profile was found
    if [ -n "$suggested_profile" ]; 
        then
            echo -e "${BLUE}[+]:${RESET}First suggested profile: $suggested_profile" | tee -a "$report_file"
        else
            echo -e "${RED}[+]:${RESET}No suggested profile found." | tee -a "$report_file"
    fi

    # Checking the process list of the memory
    echo -e "${BLUE}[+]:${RESET}pslist is being recorded"
    ./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f "$file_path" --profile="$suggested_profile" pslist | tee -a "$report_file"

    sleep 2

    # Checking the network connections of the memory
    echo -e "${BLUE}[+]:${RESET}netscan is being recorded" | tee -a "$report_file"
    ./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f "$file_path" --profile="$suggested_profile" netscan | tee -a "$report_file"

    sleep 2

    # Running also connscan because some profiles do not support netscan
    echo -e "${BLUE}[+]:${RESET}connscan is being recorded" | tee -a "$report_file"
    ./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f "$file_path" --profile="$suggested_profile" connscan | tee -a "$report_file"

    sleep 2

    # Attempting to extract registry information
    echo -e "${BLUE}[+]:${RESET}hivelist is being recorded" | tee -a "$report_file"
    ./volatility_2.6_lin64_standalone/volatility_2.6_lin64_standalone -f "$file_path" --profile="$suggested_profile" hivelist | tee -a "$report_file"
    
    
    # Checking if strings is installed and if not, installing it
    if ! command -v strings &>/dev/null; 
        then
            echo -e "${BLUE}[+]:${RESET}Installing strings..."
            sudo apt update >/dev/null 2>&1
            sudo apt install binutils -y >/dev/null 2>&1
            echo "Strings has been installed" | tee -a "$report_file"
    fi

    echo -e "${BLUE}[+]:${RESET}Running strings on $file_path..."
    strings "$file_path" > ./automated_analyzer_results/strings_output.txt 
    
    echo -e "${BLUE}[+]:${RESET}strings has been used on $file_path. Please check strings_output.txt for more information" >> "$report_file"
    
}

sleep 1

# Analyzing HDD file:
analyze_hdd() {

 echo -e "${BLUE}[+]:${RESET}File type: HDD" | tee -a "$report_file"

    # Checking if foremost is installed and if not, installing it
    if ! command -v foremost &>/dev/null; 
        then
            echo -e "${BLUE}[+]:${RESET}Installing foremost..."
            sudo apt update >/dev/null 2>&1
            sudo apt install foremost -y >/dev/null 2>&1
            echo "Foremost has been installed" | tee -a "$report_file"
    fi

    echo -e "${BLUE}[+]:${RESET}Running foremost on $file_path..."
    foremost -i "$file_path" -o ./automated_analyzer_results/foremost_output 

    echo -e "${BLUE}[+]:${RESET}foremost has been used on $file_path. Please check foremost_output for more information" >> "$report_file"

    # Count the number of files found by foremost 
    foremost_file_count=$(count_files "./automated_analyzer_results/foremost_output")
    echo -e "${BLUE}[+]:${RESET}Number of files found by foremost: $foremost_file_count" | tee -a "$report_file"
    
    sleep 2

    # Checking if strings is installed and if not, installing it
    if ! command -v strings &>/dev/null; 
        then
            echo -e "${BLUE}[+]:${RESET}Installing strings..."
            sudo apt update >/dev/null 2>&1
            sudo apt install binutils -y >/dev/null 2>&1
            echo "Strings has been installed" | tee -a "$report_file"
    fi

    echo -e "${BLUE}[+]:${RESET}Running strings on $file_path..."
    strings "$file_path" > ./automated_analyzer_results/strings_output.txt 

    echo -e "${BLUE}[+]:${RESET}strings has been used on $file_path. Please check strings_output.txt for more information" >> "$report_file"
    
    sleep 2

    # Checking if bulk_extractor is installed and if not, installing it
    if ! command -v bulk_extractor &>/dev/null; 
        then
            echo -e "${BLUE}[+]:${RESET}Installing bulk_extractor..."
            sudo apt update >/dev/null 2>&1
            sudo apt install bulk-extractor -y >/dev/null 2>&1
            echo "Bulk_extractor has been installed" | tee -a "$report_file"
    fi

    echo -e "${BLUE}[+]:${RESET}Running bulk_extractor on $file_path..."
    bulk_extractor -o ./automated_analyzer_results/bulk_extractor_output "$file_path"
    
    
    # Count the number of files found by bulk_extractor
    bulk_file_count=$(count_files "./automated_analyzer_results/bulk_extractor_output")
    echo -e "${BLUE}[+]:${RESET}Number of files with data found by bulk_extractor: $bulk_file_count" | tee -a "$report_file"
    

    echo -e "${BLUE}[+]:${RESET}bulk_extractor has been used on $file_path. Please check bulk_extractor_output for more information" >> "$report_file"
    
    sleep 2

    # Search for pcap files in bulk_extractor output
    cd ./automated_analyzer_results/bulk_extractor_output 
    pcap_files=$(grep -irl "pcap" . | grep -E "\.pcap$")

    cd ..

    if [ -z "$pcap_files" ]; 
        then
            echo -e "${BLUE}[+]:${RESET}No PCAP files found." | tee -a ../"$report_file"
        else
            for pcap_file in $pcap_files; 
            do
                file_size=$(du -h "$pcap_file" | cut -f1)
                echo -e "${BLUE}[+]:${RESET}PCAP file found: $pcap_file" | tee -a ../"$report_file"
                echo -e "${BLUE}[+]:${RESET}Size: $file_size" | tee -a ../"$report_file"
            done
    fi

    cd ..

}


# Call the appropriate analysis function based on user input & Getting information about the file the user wants to analyze - HDD or memory in order to use the right tools.
while true; 
    do
        read -p "Hello! Welcome to the automated file analyzer. Please choose the number of the file type you wish to analyze (1 for Memory, 2 for HDD): " file_type
        if [[ "$file_type" == "1" || "$file_type" == "2" ]]; 
            then
                break
            else
                echo -e "${RED}Invalid option. Please choose 1 for Memory or 2 for HDD."${RESET}
        fi
done



# Get the path of the file and make sure it exists - if not, the user can correct it
get_file_path() {
    read -p "Enter the full path of the file: " file_path
}
# Prompt the user for the file path
get_file_path 

# Check if the file exists
while [ ! -e "$file_path" ]; 
    do
        echo -e "${RED}[+]The file does not exist at $file_path. Please try again"${RESET}
        get_file_path
done

echo -e "${BLUE}[+]:${RESET}The file you chose is $file_path." | tee -a "$report_file"

if [ "$file_type" == 1 ]; 
    then
        analyze_memory
    else 
        analyze_hdd
    fi
    
    

# Zip the contents of the automated_analyzer_results directory
output_zip="analysis_results.zip"
zip -r analysis_results.zip automated_analyzer_results/

echo -e "${GREEN}[+]:${RESET}Results and report have been zipped into $output_zip"
