#!/bin/bash

set -euo pipefail

KUBECTL_VERSION="v1.32.0"

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
