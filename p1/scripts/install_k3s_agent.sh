#!/bin/bash

CONFIG_SRC="/vagrant/confs/config-agent.yaml"
CONFIG_DST="/etc/rancher/k3s/config.yaml"

# Wait for K3s server to be ready
SERVER="https://192.168.56.110:6443"
TIMEOUT=60
while ! curl -k --silent --output /dev/null --connect-timeout 5 "$SERVER"; do
    sleep 2
    TIMEOUT=$((TIMEOUT - 2))
    if [ "$TIMEOUT" -le 0 ]; then
        echo "Error: K3s server is not responding after 60 seconds."
        exit 1
    fi
done

echo "K3s server is accessible. Preparing configuration..."

# Verify that config-agent.yaml file exists
if [ ! -f "$CONFIG_SRC" ]; then
    echo "Error: File $CONFIG_SRC was not found."
    exit 1
fi

# Create /etc/rancher/k3s directory if it doesn't exist
if [ ! -d "/etc/rancher/k3s" ]; then
    echo "Creating directory /etc/rancher/k3s..."
    sudo mkdir -p /etc/rancher/k3s
fi

echo "Copying K3s agent configuration..."
sudo cp "$CONFIG_SRC" "$CONFIG_DST"

if [ -f "$CONFIG_DST" ]; then
    echo "Configuration copied successfully!"
else
    echo "Error: Configuration file copy failed."
    exit 1
fi

sudo chmod 644 "$CONFIG_DST"

ls

cat $CONFIG_DST

echo "Configuration copied successfully! Installing K3s agent..."

# Install K3s agent
export INSTALL_K3S_EXEC="agent --config /etc/rancher/k3s/config.yaml"

curl -sfL https://get.k3s.io/ | sh -


echo 'alias k="kubectl"' | sudo tee /etc/profile.d/kubectl_alias.sh > /dev/null
sudo chmod +x /etc/profile.d/kubectl_alias.sh


echo "K3s agent installation completed."
