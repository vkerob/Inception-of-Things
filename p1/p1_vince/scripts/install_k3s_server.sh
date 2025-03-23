#!/bin/bash

echo "Installation de K3s en mode contrôleur sur jvasseurS..."

# Correction de la commande curl
curl -sfL https://get.k3s.io/ | sudo K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server --flannel-iface eth1" sh -

echo "Copie du token pour les agents..."
sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/token

echo "Installation terminée ! K3s est prêt."
