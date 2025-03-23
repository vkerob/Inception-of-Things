#!/bin/bash

echo "Installation de K3s en mode agent sur jvasseurSW..."

SERVER_IP="192.168.56.110"
K3S_TOKEN_FILE="/vagrant/token"

if [ ! -f "$K3S_TOKEN_FILE" ]; then
    echo "Erreur : le fichier token n'existe pas à $K3S_TOKEN_FILE"
    exit 1
fi

TOKEN=$(cat "$K3S_TOKEN_FILE")

curl -sfL https://get.k3s.io | K3S_URL="https://$SERVER_IP:6443" K3S_TOKEN="$TOKEN" sh -
