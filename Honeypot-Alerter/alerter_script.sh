#!/bin/bash

# Alerter_script: Real-time monitoring and scanning for honeypot activity

# Real-time monitoring and scanning the activity from the results using scanner_script
tail -F alerter.txt | while read -r line; do
    if [[ $line =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ && "$line" != "0.0.0.0" ]]; then
        echo "IP address detected: $line"
        read -p "Do you want to run scanner_script? (y/n): " answer
        if [ "$answer" == "y" ]; then
            ./scanner_script  
        else
            echo "Caught someone! Run scanner_script manually for more information! :) "
        fi
    fi
done
