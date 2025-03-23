#!/bin/bash

echo "Installation de K3s en mode contrôleur sur jvasseurS..."

K3S_KUBECONFIG_MODE="644"
INSTALL_K3S_EXEC="server --node-external-ip=192.168.56.110 --bind-adress=192.168.56.110 --flannel-iface eth1"

curl -sfL https://get.k3s.io/ | sh - 


cp /var/lib/rancher/k3s/server/node-token /vagrant/token

