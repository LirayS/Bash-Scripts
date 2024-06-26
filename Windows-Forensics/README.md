# Windows Forensics Toolkit
# 1) Automated File Analyzer
#
# The Automated File Analyzer script is a bash script designed to analyze memory and HDD files using carving tools like bulk_extractor and volatility. 
# It aims to automate the analysis process and generate comprehensive reports of the findings.
#
# Features
# Memory Analysis: Analyzes memory files using Volatility, including extracting process lists, network connections, and registry information.
# HDD Analysis: Analyzes HDD files using Foremost, Bulk Extractor, and strings, including extracting files, searching for PCAP files, and generating string output.
# Reporting: Generates a detailed report of the analysis results, including suggested profiles, extracted information, and file counts.
# User-Friendly Interface: Prompts the user to choose the file type (memory or HDD) and provides guidance for entering the file path.
#
# 2) Memory&Nmap 
# 
# Features
# Bulk Extraction with bulk_extractor: Extracts information from the memory image using bulk_extractor and specifically targets URLs and extracts them into a file.
# Domain Extraction: Parses the extracted URLs to isolate domain names and cleans the URLs by removing unnecessary characters.
# Network Scanning with nmap: Performs network scans on the top 10 domain names extracted from output file.
# 
# Installation
# git clone https://github.com/LirayS/Bash-Scripts.git
# cd Windows-Forensics
# chmod +x Automated_file_analyzer.sh
# sudo ./Automated_file_analyzer.sh or ./memory&nmap.sh
#
# Disclaimer
# This script is intended for forensic analysis and informational purposes only. The author and contributors of this script are not responsible for any misuse or illegal activities conducted using this tool.
