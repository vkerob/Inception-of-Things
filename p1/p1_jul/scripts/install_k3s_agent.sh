#!/bin/bash


echo "Installation de K3s en mode agent sur jvasseurSW..."



K3S_URL="192.168.56.110"
export K3S_TOKEN_FILE="/vagrant/token"

curl -sfL https://get.k3s.io/ | INSTALL_K3S_EXEC="agent --server https://$K3S_URL:6443 --flannel-iface eth1 --token $K3S_TOKEN_FILE" sh -