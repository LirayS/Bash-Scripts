#!/bin/bash

# This script will gather some info from the memory image using bulk_extractor and nmap
# Performing bulk_extractor on the image file

read -p "Please enter the full path for the image: " image

bulk_extractor "$image" -o bulk_output

cd bulk_output

# Extracting domain names out of url.txt

cat url.txt | grep -oE 'https?://\S+' | awk -F[/:] '{print $4}' | sed 's#^https\?://##; s#\\.*##' | sort -u  > ../domains.txt

echo "domains.txt has been created successfully"

# Performing nmap on specific ports on the top 10 domain names extracted from the url.txt

head -n 10 ../domains.txt | xargs nmap -p 80,22,21,23 -oN ../nmap_output > /dev/null 2>&1

echo "nmap_output file has been created successfully"

# Display the nmap scan results

cat ../nmap_output
