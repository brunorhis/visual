#!/bin/bash

# Function to check if a given IP is valid
is_valid_ip() {
    local ip=$1
    local regex='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
    regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
    regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
    regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

    if [[ $ip =~ $regex ]]; then
        ip_alvo=$1
    else
        echo "[+] Provide an valid IP as an argument"
	exit 1
    fi
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "[+] This script must be run as root. Please use sudo or elevate your privileges."
    exit 1
fi

# Check if the first argument is a valid IP
if [ -n "$1" ]; then
    is_valid_ip "$1"
else
    echo "[+] Usage mode: ./nmap1.sh 'valid ip value'"
    echo "[+] ex: ./nmap1.sh 192.168.1.1"
    exit 1
fi

# Get the current date and time in the format YYYYMMDD_HHMMSS
current_datetime=$(date +"%Y%m%d_%H%M%S")

# Create a folder with the current date, time, and IP address
folder_name="${current_datetime}_${ip_alvo}"

# Create the folder and change into it
mkdir /tmp/"$folder_name" && cd /tmp/"$folder_name"

#Fast Scan TCP

# Run a fast scan on TCP ports and save the output to a file
nmap -sS -D RND:20 -Pn -n "$ip_alvo" -oG Fast_TCP_$ip_alvo && curl -d "Fast TCP is done." http://ntfy.sh/A-001 || curl -d "Fast TCP failed." http://ntfy.sh/A-001

# Display a message when finishes
echo "Scan fast TCP is done. Path:/tmp/"$folder_name"/Fast_TCP_$ip_alvo "

# Scan TCP all ports
nmap -sS -sV -D RND:20 -p- -Pn -n "$ip_alvo" -oG ALL_TCP_PORTS_$ip_alvo && curl -d "ALL TCP PORTS is done." http://ntfy.sh/A-001 || curl -d "ALL TCP PORTS failed." http://ntfy.sh/A-001

# Display a message when finishes
echo "Scan ALL TCP PORTs is done. Path:/tmp/"$folder_name"/ALL_TCP_PORTS_$ip_alvo"

# Scan TCP all ports script
nmap -sT --script=vuln -D RND:20 -p- -Pn -n "$ip_alvo" -oG Script_$ip_alvo && curl -d "Script is done." http://ntfy.sh/A-001 || curl -d "Script Failed." http://ntfy.sh/A-001

# Display a message when finishes
echo "Scan Script is done. Path:/tmp/"$folder_name"/Script_$ip_alvo"

# Scan Top Ports UDP
nmap -sU -D RND:20 -Pn -n "$ip_alvo" -oG UDP_$ip_alvo && curl -d "UDP is done." http://ntfy.sh/A-001 || && curl -d "UDP is failed." http://ntfy.sh/A-001

# Display a message when finishes
echo "Scan Script is done. Path:/tmp/"$folder_name"/UDP_$ip_alvo"

echo "Finish... "
exit 1
