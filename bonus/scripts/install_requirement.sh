#!/bin/bash

set -euo pipefail

KUBECTL_VERSION="v1.32.0"
SWAPFILE="/swapfile"
SWAPSIZE_GB=10
SWAPSIZE_BYTES=$((SWAPSIZE_GB * 1024 * 1024 * 1024))

echo "Script d'installation de l'environnement K3D + outils"

# === Fonctions de vérification ===
function is_installed() {
    command -v "$1" >/dev/null 2>&1
}

# === Docker ===
if is_installed docker; then
    echo "Docker est déjà installé"
 else 
    echo "Installation de Docker..."

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

    echo "Ajout de $USER au groupe docker"
    sudo usermod -aG docker $USER
fi

# === k3d ===
if is_installed k3d; then
    echo "k3d est déjà installé"
else
    echo "Installation de k3d..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# === kubectl ===
if ! is_installed kubectl; then
    echo "Installation de kubectl..."

    KUBECTL_VERKUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)

    if [[ -z "$KUBECTL_VERSION" ]]; then
        echo "Impossible de récupérer la dernière version de kubectl, utilisation d'une version par défaut"
    fi

    echo "Téléchargement de kubectl version : $KUBECTL_VERSION"

    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl est déjà installé"
fi

# === Helm ===
if is_installed helm; then
    echo "Helm est déjà installé"
else
    echo "Installation de Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "Vérification de l'état du swap..."
if swapon --show | grep -q "$SWAPFILE"; then
    echo "Swap déjà actif. Aucune action nécessaire."
    free -h
    exit 0
fi

echo "Vérification de l'espace disque disponible..."
AVAILABLE_BYTES=$(df --output=avail / | tail -1)
AVAILABLE_BYTES=$((AVAILABLE_BYTES * 1024))

if (( AVAILABLE_BYTES < SWAPSIZE_BYTES )); then
    echo "Pas assez d'espace disque pour créer ${SWAPSIZE_GB}G de swap."
    echo "Dispo : $((AVAILABLE_BYTES / 1024 / 1024)) MiB, Requis : $((SWAPSIZE_BYTES / 1024 / 1024)) MiB"
    exit 1
fi

echo "Création du fichier de swap (${SWAPSIZE_GB}G)..."
sudo fallocate -l "${SWAPSIZE_GB}G" "$SWAPFILE" || sudo dd if=/dev/zero of="$SWAPFILE" bs=1M count=$((SWAPSIZE_GB * 1024)) status=progress

echo "Permissions..."
sudo chmod 600 "$SWAPFILE"

echo "Initialisation du swap..."
sudo mkswap "$SWAPFILE"

echo "Activation du swap..."
sudo swapon "$SWAPFILE"

echo "Configuration persistante..."
grep -q "$SWAPFILE" /etc/fstab || echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab

echo "Réglage de vm.swappiness à 20..."
sudo sysctl vm.swappiness=20
grep -q 'vm.swappiness' /etc/sysctl.conf || echo 'vm.swappiness=20' | sudo tee -a /etc/sysctl.conf

echo "Swap configuré avec succès !"
free -h
