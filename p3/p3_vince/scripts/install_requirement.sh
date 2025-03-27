#!/bin/bash

set -e

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
        KUBECTL_VERSION="v1.32.0"
    fi

    echo "Téléchargement de kubectl version : $KUBECTL_VERSION"

    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl est déjà installé"
fi

# === argocd (facultatif, mais utile pour la suite) ===
if is_installed argocd; then
    echo "argocd CLI est déjà installé"
else
    echo "Installation de l'outil en ligne de commande Argo CD..."
    curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    chmod +x argocd
    sudo mv argocd /usr/local/bin/
fi
