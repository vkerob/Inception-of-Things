#!/bin/bash

CONFIG_SRC="/vagrant/confs/config-server.yaml"
CONFIG_DST="/etc/rancher/k3s/config.yaml"

echo "Installing K3s in controller mode on jvasseurS..."

# Check if configuration file exists in /vagrant/confs
if [ ! -f "$CONFIG_SRC" ]; then
    echo "Error: Configuration file $CONFIG_SRC not found."
    exit 1
fi

# Create configuration directory if it doesn't exist
sudo mkdir -p /etc/rancher/k3s

# Copy and rename configuration file
echo "Copying K3s server configuration..."
sudo cp "$CONFIG_SRC" "$CONFIG_DST"
sudo chmod 644 "$CONFIG_DST"

export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="server --config /etc/rancher/k3s/config.yaml"

curl -sfL https://get.k3s.io/ | sh - 

echo 'alias k="kubectl"' | sudo tee /etc/profile.d/kubectl_alias.sh > /dev/null
sudo chmod +x /etc/profile.d/kubectl_alias.sh

