#!/bin/bash

# Check if the user has provided a public key as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 \"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINetVzRgShomRm/5j/Hp6ohRqMrpUMmIC1ymFHSAaw1p secon@timcook\""
  exit 1
fi

# Assign the provided public key to a variable
PUBLIC_KEY="$1"

# Make sure the .ssh directory exists
mkdir -p ~/.ssh

# Append the public key to the authorized_keys file, ensuring no duplicates
grep -qxF "$PUBLIC_KEY" ~/.ssh/authorized_keys || echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys

# Set the correct permissions for the .ssh directory and authorized_keys file
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Backup the current SSHD configuration
SSHD_CONFIG="/etc/ssh/sshd_config"
SSHD_CONFIG_BACKUP="/etc/ssh/sshd_config.bak"

if [ ! -f "$SSHD_CONFIG_BACKUP" ]; then
  sudo cp "$SSHD_CONFIG" "$SSHD_CONFIG_BACKUP"
fi

# Enable ProhibitRootLogin, disable PasswordAuthentication, enable PubkeyAuthentication
sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' $SSHD_CONFIG
sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' $SSHD_CONFIG
sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSHD_CONFIG

# Restart the SSH service to apply changes
sudo systemctl restart sshd

echo "SSH configuration updated, public key added, and service restarted."
