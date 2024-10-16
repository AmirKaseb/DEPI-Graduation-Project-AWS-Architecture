#!/bin/bash

# Prompt for the public IP address
read -p "Enter the bastion host public IP address: " bastion_host_ip

# Prompt for the private IP address
read -p "Enter the private IP address: " private_ip

# Prompt for the local port
read -p "Enter the local port (default 8080): " local_port
local_port=${local_port:-8080}  # Use 8080 as default if no input

# Prompt for the remote port
read -p "Enter the remote port (default 8080): " remote_port
remote_port=${remote_port:-8080}  # Use 8080 as default if no input

# Execute the SSH command with the provided IPs and ports
ssh -i ~/.ssh/DEPI -L ${local_port}:${private_ip}:${remote_port} ubuntu@${bastion_host_ip}
