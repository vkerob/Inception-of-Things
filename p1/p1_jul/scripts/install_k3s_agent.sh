#!/bin/bash

TIMEOUT=15
while [ ! -f "/vagrant/token" ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -eq 0 ]; then
        echo "Token file not found."
        exit 1
    fi
done



echo "Installation de K3s en mode agent sur jvasseurSW..."
export TOKEN=$(cat /vagrant/token)
export K3S_URL=https://192.168.56.110:6443 
export K3S_TOKEN_FILE=/vagrant/token

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 --flannel-iface eth1 --token $TOKEN" sh -
