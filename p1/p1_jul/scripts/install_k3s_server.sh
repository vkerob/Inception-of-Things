#!/bin/bash

echo "Installation de K3s en mode contrôleur sur jvasseurS..."


curl -sfL https://get.k3s.io/ | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="server --flannel-iface eth1" sh - 


cp /var/lib/rancher/k3s/server/node-token /vagrant/token

