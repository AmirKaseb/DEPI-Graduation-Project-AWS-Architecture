#!/bin/bash

# Update the system's package index
sudo apt update -y

# Install software-properties-common if not installed
sudo apt install -y software-properties-common

# Add Ansible PPA (Personal Package Archive)
sudo add-apt-repository --yes --update ppa:ansible/ansible

# Install Ansible
sudo apt install -y ansible

# Confirm Ansible installation by checking its version
ansible --version

# Output message on successful Ansible installation
if [ $? -eq 0 ]; then
    echo "Ansible installed successfully!"
else
    echo "Ansible installation failed."
    exit 1
fi

# Generate SSH key pair
SSH_DIR=~/.ssh
KEY_NAME="DEPI"
KEY_PATH="$SSH_DIR/$KEY_NAME"

# Create .ssh directory if it doesn't exist
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Check if the SSH key already exists
if [ -f "$KEY_PATH" ]; then
    echo "SSH key $KEY_NAME already exists. Skipping key generation."
else
    # Prompt the user for a passphrase
    echo -n "Enter passphrase for the SSH key (leave empty for no passphrase): "
    read -s passphrase
    echo

    # Generate the SSH key with the provided passphrase
    echo "Generating SSH key pair named $KEY_NAME..."
    ssh-keygen -t ed25519 -C "DEPI Key Pair" -f "$KEY_PATH" -N "$passphrase"
    echo "SSH key pair generated at $KEY_PATH."
fi

# Create or update ~/.bash_aliases file
BASH_ALIASES_FILE=~/.bash_aliases
ALIAS_COMMAND="alias ssha='eval \$(ssh-agent) && ssh-add'"

# Check if .bash_aliases exists, if not create it
if [ ! -f "$BASH_ALIASES_FILE" ]; then
    touch "$BASH_ALIASES_FILE"
    echo "Created ~/.bash_aliases."
fi

# Check if the alias already exists in the file
if ! grep -q "$ALIAS_COMMAND" "$BASH_ALIASES_FILE"; then
    echo "$ALIAS_COMMAND" >> "$BASH_ALIASES_FILE"
    echo "Added alias 'ssha' to ~/.bash_aliases."
else
    echo "Alias 'ssha' already exists in ~/.bash_aliases."
fi

# Reload .bash_aliases to make the alias immediately available
source ~/.bash_aliases

# If a passphrase was provided, execute the alias command
if [ -n "$passphrase" ]; then
    echo "Executing alias 'ssha' to add the SSH key..."
    eval $(ssh-agent) && ssh-add "$KEY_PATH"
else
    echo "No passphrase was provided, skipping ssh-add."
fi

# Output the public key for verification
echo "Here is the public key:"
cat "$KEY_PATH.pub"
