#!/bin/bash

CONFIG_SRC="/vagrant/confs/config-server.yaml"
CONFIG_DST="/etc/rancher/k3s/config.yaml"

echo "Installation de K3s en mode contrôleur sur jvasseurS..."

# Vérifier si le fichier de configuration existe dans /vagrant/confs
if [ ! -f "$CONFIG_SRC" ]; then
    echo "Erreur : Le fichier de configuration $CONFIG_SRC n'a pas été trouvé."
    exit 1
fi

# Création du répertoire de configuration s'il n'existe pas
sudo mkdir -p /etc/rancher/k3s

# Copie et renommage du fichier de configuration
echo "Copie de la configuration du serveur K3s..."
sudo cp "$CONFIG_SRC" "$CONFIG_DST"
sudo chmod 644 "$CONFIG_DST"

echo "Installation du serveur K3s..."

# Installation du serveur K3s
export K3S_KUBECONFIG_MODE="644"
export INSTALL_K3S_EXEC="server --config /etc/rancher/k3s/config.yaml"

curl -sfL https://get.k3s.io/ | sh -


# Vérifier que le fichier `node-token` est bien généré avant de continuer
echo "Attente de la génération du token..."
TIMEOUT=30
while [ ! -f "/var/lib/rancher/k3s/server/node-token" ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ "$TIMEOUT" -eq 0 ]; then
        echo "Erreur : Le token K3s n'a pas été généré après 30 secondes."
        exit 1
    fi
done

# Lecture du token
TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
SERVER="https://192.168.56.110:6443"

echo "Écriture du token dans config-agent.yaml..."
sudo tee /vagrant/confs/config-agent.yaml > /dev/null <<EOF
server: "$SERVER"
token: "$TOKEN"
flannel-iface: "eth1"
EOF


echo 'alias k="kubectl"' | sudo tee /etc/profile.d/kubectl_alias.sh > /dev/null
sudo chmod +x /etc/profile.d/kubectl_alias.sh


echo "Installation terminée ! K3s est prêt."
