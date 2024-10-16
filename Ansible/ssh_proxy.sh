#!/bin/bash

# Prompt for the bastion host public IP address
read -p "Enter the bastion host public IP address: " bastion_host_ip

# Prompt for the private IP address
read -p "Enter the private IP address: " private_ip

# Execute the SSH command with the provided IPs
ssh -o ProxyCommand="ssh -W %h:%p ubuntu@${bastion_host_ip}" ubuntu@${private_ip}
