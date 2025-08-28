# netCheck
This Bash script provides a user-friendly menu for performing various network diagnostics and utilities. Users can check connectivity, trace  routes, perform DNS lookups, monitor network traffic, and more. The results of each command are logged for future reference. This script still requires a lot of testing. ALPHA

## Features

- **Check Connectivity**: Ping a specified domain to measure latency and packet loss.
- **Trace Route**: Trace the route packets take to reach a specified domain.
- **DNS Lookup**: Retrieve DNS records for a specified domain.
- **Network Interfaces**: List all network interfaces and their statuses.
- **Active Connections**: Display all active network connections.
- **Firewall Status**: Check the status of the firewall and list active rules.
- **Monitor Traffic**: Observe network traffic in real-time.
- **Network Configuration**: Display and modify network configuration settings.
- **Speed Test**: Check internet connection speed.
- **Port Scan**: Scan for open ports on a specified domain or IP address.
- **Troubleshooting**: Provide suggestions based on diagnostic results.

## Requirements

- Bash shell
- Necessary utilities installed:
  - `ping`
  - `traceroute`
  - `dig`
  - `nmcli`
  - `ss`
  - `iptables`
  - `iftop`
  - `speedtest`
  - `nmap`

## Logging

All command outputs are logged to `~/.util_log/netcheck.log`. If the directory or file does not exist, the script will create them automatically.



