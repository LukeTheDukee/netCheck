#!/bin/bash

user_menu() {
  printf "\nHello! Select an option:\n"
  printf "1) Check connectivity to specifc domain\n"
  printf "2) Trace the route to a domain\n"
  printf "3) Lookup DNS records for a domain\n"
  printf "4) List network interfaces and their statuses\n"
  printf "5) Display active network connections\n"
  printf "6) Check firewall status and rules\n"
  printf "7) Monitor network traffic in real-time\n"
  printf "8) Display and change network configuration settings\n"
  printf "9) Check internet connection speed\n"
  printf "10) Scan for open ports on a domain or IP address\n"
  printf "11) Troubleshoot issues based on diagnostics\n"
  printf "q) Quit\n"

  read -rp "Enter your choice (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 or Quit\n): " choice

  case $choice in # All cases log output to file (Home/.util_log/netcheck.log)
  1)
    log_output ping_domain
    ;;

  2)
    log_output trace_route
    ;;
  3)
    log_output dns_lookup
    ;;
  4)
    log_output list_network_interfaces
    ;;
  5)
    log_output active_connections
    ;;
  6)
    log_output firewall_status
    ;;
  7)
    log_output observe_traffic
    ;;
  8)
    log_output network_config
    ;;
  9)
    log_output speed_test
    ;;
  10)
    log_output port_scan
    ;;
  11)
    troubleshoot
    ;;
  [Qq]uit)
    echo "Goodbye!"
    exit 0
    ;;
  *)
    echo "Invalid choice. Please try again."
    user_menu
    ;;
  esac
}

diagnostic_result=""

# Function to check if user has sudo privileges
check_sudo() {
  if ! command -v sudo &>/dev/null; then
    echo "sudo command not found. Please install sudo to run this script."
    exit 1
  fi

  if ! sudo -n true 2>/dev/null; then
    echo "This script requires sudo privileges. Please run the script with a user that has sudo access."
    exit 1
  fi
}

# Simple logging function to log output of commands to a file with timestamps.
log_output() {
  local logfile
  local output
  local command_name

  if [[ ! -d "$HOME/.util_log" ]]; then
    mkdir "$HOME/.util_log" # Is directory there?
  fi

  if [[ ! -f "$HOME/.util_log/netcheck.log" ]]; then
    touch "$HOME/.util_log/netcheck.log" # is file there?
  fi

  logfile="$HOME/.util_log/netcheck.log"
  output="$("$@" 2>&1)" # Capture both stdout and stderr

  echo "$output" | tee -a "$logfile"               # Send output to both console and log file
  diagnostic_result+="$command_name: $output"$'\n' # Store output in a global variable for further processing if needed
}

# Fucntion to check if package is installed
check_package() {
  local package
  package=$(command -v "$1") # Check if package is installed

  if [[ ! "$package" ]]; then
    echo "$1 is not installed. Please install $1 to use this feature."
    return 1
  fi
}

# Function to check connectivity to a specified domain. Measures latency and packet loss.
ping_domain() {
  read -rp "Enter the domain to ping (e.g., google.com): " domain
  if [[ -z "$domain" ]]; then
    echo "Domain cannot be empty. Please try again." # Error handling for empty input
    ping_domain                                      # Recursively call the function to prompt again
    return                                           # Ensure the function exits after the recursive call
  fi

  check_package ping || return 1 # Check if ping is installed

  # Perform the ping with a timestamp
  echo "Pinging $domain for 10 packets..."
  if ping -c 10 "$domain" | while read -r pong; do
    echo "$(date): $pong"
  done; then
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to trace the route to a domain. Displays each hop and time it takes along the path.
trace_route() {
  read -rp "Enter the domain to trace (e.g., google.com): " domain
  if [[ -z "$domain" ]]; then
    echo "Domain cannot be empty. Please try again." # Error handling for empty input
    trace_route                                      # Recursively call the function to prompt again
    return                                           # Ensure the function exits after the recursive call
  fi

  check_package traceroute || return 1 # Check if traceroute is installed

  # Perform the traceroute
  echo "Tracing route to: $domain"
  if traceroute "$domain" | while read -r route; do
    echo "$(date): $route"
  done; then
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to perform a DNS lookup for a given domain.
dns_lookup() {
  read -rp "Enter the domain for DNS lookup (e.g., google.com): " domain
  if [[ -z "$domain" ]]; then
    echo "Domain cannot be empty. Please try again." # Error handling for empty input
    dns_lookup                                       # Recursively call the function to prompt again
    return                                           # Ensure the function exits after the recursive call
  fi

  check_package dig || return 1 # Check if dig is installed

  # Perform the DNS lookup with dig
  echo "Performing DNS lookup for: $domain"
  if dig "$domain" A +noall +answer | while read -r record; do
    echo "$(date): A Record: $record"
  done; then
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to display network interfaces and their statuses.
list_network_interfaces() {
  check_package nmcli || return 1 # Check if nmcli is installed

  # Get the status of network devices
  echo "Network Interfaces Status as of $(date):"
  if nmcli device status | awk 'NR>1 {print $1, "-", $3}'; then
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to display active network connections.
active_connections() {
  check_package ss || return 1 # Check if ss is installed

  echo "Active Network Connections:"
  if ss -tuln | while read -r conn; do # Displays all active TCP and UDP connections with numeric addresses and ports.
    echo "$(date): $conn"
  done; then
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to check firewall status and list of active rules and configurations.
firewall_status() {
  check_package iptables || return 1 # Check if iptables is installed

  echo "Active Firewall Rules:"
  if iptables -L -n -v | while read -r rule; do # Lists all active firewall rules.
    echo "$(date): $rule"
  done; then
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to monitor the network traffic in real-time.
observe_traffic() {
  check_package iftop || return 1 # Check if iftop is installed

  echo "Monitoring network traffic. Press Ctrl+C to stop."
  if sudo iftop -n | while read -r traffic; do # Monitors network traffic in real-time.
    echo "$(date): $traffic"
  done; then
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to display current network configuration settings and change them if needed.
network_config() {
  check_package nmcli || return 1 # Check if nmcli is installed

  echo "Current Network Configuration:"
  if nmcli connection show; then # Displays current network configuration settings.
    echo "Configuration displayed successfully."
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi

  read -rp "Do you want to change any settings? (y/n): " change

  if [[ "$change" == "y" || "$change" == "Y" ]]; then # If choice is yes, prompt for new settings
    read -rp "Enter the connection name to modify: " conn_name
    if [[ -z "$conn_name" ]]; then # Check for empty input
      echo "Connection name cannot be empty. No changes made."
      return 1
    fi

    read -rp "Enter the new IP address (e.g., 192.168.1.100): " ip_address
    if [[ -z "$ip_address" ]]; then # Check for empty input
      echo "IP address cannot be empty. No changes made."
      return 1
    fi

    # Edit the connection with the new IP address
    sudo nmcli connection modify "$conn_name" ipv4.addresses "$ip_address" ipv4.method manual
    echo "Configuration for $conn_name updated to use IP address $ip_address."
  elif [[ "$change" == [Nn] ]]; then
    echo "No changes made."
  else
    echo "Invalid input. Please enter 'y' or 'n'." # Default case for invalid input
  fi
}

# Function to check internet connection speed
speed_test() {
  check_package speedtest || return 1 # Check if speedtest is installed

  echo -e "Running internet speed test...\n"
  if speedtest | while read -r result; do # Runs a simple speed test. Dload and upload speeds.
    echo "$(date): $result"
  done; then
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to scan for open ports on a specified domain or IP address.
port_scan() {
  check_package nmap || return 1 # Check if nmap is installed

  read -rp "Enter the domain or IP address to scan (e.g., google.com or localhost): " target

  if sudo nmap -n -PN -sT -sU -p- "$target" | while IFS= read -r line; do # Check for ports on localhost
    echo "$(date): $line"
  done; then
    printf "%s: Port scan completed.\n" "$(date)"
    return 0
  else
    printf "%s: Something went wrong... Please try again.\n" "$(date)"
    return 1
  fi
}

# Function to help troubleshoot issues based on the results of the diagnostics.
troubleshoot() {
  echo -e "\nTroubleshooting Suggestions:\n"

  if [[ "$diagnostic_result" == *"ping: "* ]]; then
    echo "1. Check if your network cable is connected or if you're connected to Wi-Fi."
    echo "2. Restart your router or modem."
    echo "3. Check if you are connected to the correct network."
    echo "4. Ensure your firewall or security software is not blocking the connection."
    echo "5. If you using a VPN, try disconnecting it and see if that resolves the issue."
  elif [[ "$diagnostic_result" == *"traceroute: "* ]]; then
    echo "1. If there are timeouts, check your network connection."
    echo "2 Restart your router or modem. Check for outages with your ISP."
  elif [[ "$diagnostic_result" == *"dig: "* ]]; then
    echo "1. Check your DNS settings. Ensure you're using a reliable DNS server."
    echo "2. Try flushing your DNS cache."
    echo "3. Try switching to a public DNS server like Google DNS (8.8.8.8)"
  fi

  echo -e "\nFor more detailed troubleshooting, please refer to online resources or forums related to your specific issue."
}

check_sudo # Ensure the user has sudo privileges before proceeding
while true; do
  user_menu
done
