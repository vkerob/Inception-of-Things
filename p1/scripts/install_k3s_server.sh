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

echo "Installing K3s server..."

# Installing K3s server
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="server --config /etc/rancher/k3s/config.yaml"

curl -sfL https://get.k3s.io/ | sh -


# Check that the `node-token` file is generated before continuing
echo "Waiting for token generation..."
TIMEOUT=30
while [ ! -f "/var/lib/rancher/k3s/server/node-token" ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -eq 0 ]; then
        echo "Error: K3s token was not generated after 30 seconds."
        exit 1
    fi
done

# Read the token
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
SERVER="https://192.168.56.110:6443"

echo "Writing token to config-agent.yaml..."
sudo tee /vagrant/confs/config-agent.yaml > /dev/null <<EOF
server: "$SERVER"
token: "$TOKEN"
flannel-iface: "eth1"
EOF

echo 'alias k="kubectl"' | sudo tee /etc/profile.d/kubectl_alias.sh > /dev/null
sudo chmod +x /etc/profile.d/kubectl_alias.sh


echo "Installation complete! K3s is ready."
