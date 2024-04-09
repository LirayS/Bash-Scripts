# Automated File Analyzer
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
# Installation
# git clone https://github.com/LirayS/Windows-Forensics.git
# cd Windows-Forensics
# chmod +x Automated_file_analyzer.sh
# sudo ./Automated_file_analyzer.sh
#
# Disclaimer
# This script is intended for forensic analysis and informational purposes only. The author and contributors of this script are not responsible for any misuse or illegal activities conducted using this tool.