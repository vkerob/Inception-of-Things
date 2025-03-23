#!/bin/bash
set -e

echo "Téléchargement de la dernière version stable de kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "Rendre kubectl exécutable..."
chmod +x kubectl

echo "Déplacement de kubectl dans /usr/local/bin..."
sudo mv kubectl /usr/local/bin/kubectl

echo "Installation terminée. Version de kubectl installée :"
kubectl --version 

echo "set aliases kubectl"
echo "alias k='kubectl'" >> /home/vagrant/.bashrc