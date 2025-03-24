#!/bin/bash

CONFIG_SRC="/vagrant/confs/config-agent.yaml"
CONFIG_DST="/etc/rancher/k3s/config.yaml"

# Attente que le serveur K3s soit prêt
SERVER="https://192.168.56.110:6443"
TIMEOUT=60
while ! curl -k --silent --output /dev/null --connect-timeout 5 "$SERVER"; do
    sleep 2
    TIMEOUT=$((TIMEOUT - 2))
    if [ "$TIMEOUT" -le 0 ]; then
        echo "Erreur : Le serveur K3s ne répond pas après 60 secondes."
        exit 1
    fi
done

echo "Le serveur K3s est accessible. Préparation de la configuration..."

# Vérifier que le fichier config-agent.yaml existe bien
if [ ! -f "$CONFIG_SRC" ]; then
    echo "Erreur : Le fichier $CONFIG_SRC n'a pas été trouvé."
    exit 1
fi

# Création du répertoire /etc/rancher/k3s s'il n'existe pas
if [ ! -d "/etc/rancher/k3s" ]; then
    echo "Création du répertoire /etc/rancher/k3s..."
    sudo mkdir -p /etc/rancher/k3s
fi

echo "Copie de la configuration de l'agent K3s..."
sudo cp "$CONFIG_SRC" "$CONFIG_DST"

if [ -f "$CONFIG_DST" ]; then
    echo "Configuration copiée avec succès !"
else
    echo "Erreur : La copie du fichier de configuration a échoué."
    exit 1
fi

sudo chmod 644 "$CONFIG_DST"

ls

cat $CONFIG_DST

echo "Configuration copiée avec succès ! Installation de K3s agent..."

# Installation de K3s agent
export INSTALL_K3S_EXEC="agent --config /etc/rancher/k3s/config.yaml"

curl -sfL https://get.k3s.io/ | sh -


echo 'alias k="kubectl"' | sudo tee /etc/profile.d/kubectl_alias.sh > /dev/null
sudo chmod +x /etc/profile.d/kubectl_alias.sh


echo "Installation de K3s agent terminée."
