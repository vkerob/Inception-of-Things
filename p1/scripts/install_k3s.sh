#!/bin/bash

# Si c'est le serveur (vkerobS), installe K3s en tant que contrôleur
if [ "$1" == "server" ]; then
    curl -sfL https://get.k3s.io | sh -
    echo "K3s controller installed on server"
    # Récupérer le token d'authentification pour le worker
    TOKEN=$(sudo cat /etc/rancher/k3s/k3s.yaml | grep 'token' | awk '{print $2}')
    echo "Token: $TOKEN" > /tmp/k3s_token.txt
    sudo k3s kubectl get nodes
fi

# Si c'est le worker (vkerobSW), installe K3s en tant qu'agent
if [ "$1" == "worker" ]; then
    # Lire le token depuis le fichier /tmp/k3s_token.txt
    TOKEN=$(cat /tmp/k3s_token.txt)
    K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN curl -sfL https://get.k3s.io | sh -
    echo "K3s agent installed on worker"
    sudo k3s kubectl get nodes
fi