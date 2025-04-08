#!/bin/bash

set -euo pipefail

KUBECTL_VERSION="v1.32.0"
SWAPFILE="/swapfile"
SWAPSIZE_GB=10
SWAPSIZE_BYTES=$((SWAPSIZE_GB * 1024 * 1024 * 1024))

echo "K3D environment + tools installation script"

# === Check functions ===
function is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# === Docker ===
if is_installed docker; then
    echo "Docker is already installed"
 else 
    echo "Installing Docker..."

    sudo apt update
    sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    echo "Adding $USER to docker group"
    sudo usermod -aG docker $USER
fi

# === k3d ===
if is_installed k3d; then
    echo "k3d is already installed"
else
    echo "Installing k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# === kubectl ===
if ! is_installed kubectl; then
    echo "Installing kubectl..."

    KUBECTL_VERKUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)

    if [[ -z "$KUBECTL_VERSION" ]]; then
        echo "Unable to get latest kubectl version, using default version"
    fi

    echo "Downloading kubectl version: $KUBECTL_VERSION"

    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl is already installed"
fi

# === Helm ===
if is_installed helm; then
    echo "Helm is already installed"
else
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "Checking swap status..."
if swapon --show | grep -q "$SWAPFILE"; then
    echo "Swap already active. No action required."
    free -h
    exit 0
fi

echo "Checking available disk space..."
AVAILABLE_BYTES=$(df --output=avail / | tail -1)
AVAILABLE_BYTES=$((AVAILABLE_BYTES * 1024))

if (( AVAILABLE_BYTES < SWAPSIZE_BYTES )); then
    echo "Not enough disk space to create ${SWAPSIZE_GB}G of swap."
    echo "Available: $((AVAILABLE_BYTES / 1024 / 1024)) MiB, Required: $((SWAPSIZE_BYTES / 1024 / 1024)) MiB"
    exit 1
fi

echo "Creating swap file (${SWAPSIZE_GB}G)..."
sudo fallocate -l "${SWAPSIZE_GB}G" "$SWAPFILE" || sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count=$((SWAPSIZE_GB * 1024)) status=progress

echo "Setting permissions..."
sudo chmod 600 "$SWAPFILE"

echo "Initializing swap..."
sudo mkswap "$SWAPFILE"

echo "Activating swap..."
sudo swapon "$SWAPFILE"

echo "Persistent configuration..."
grep -q "$SWAPFILE" /etc/fstab || echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab

echo "Setting vm.swappiness to 20..."
sudo sysctl vm.swappiness=20
grep -q 'vm.swappiness' /etc/sysctl.conf || echo 'vm.swappiness=20' | sudo tee -a /etc/sysctl.conf

echo "Swap configured successfully!"
free -h
