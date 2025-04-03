#!/bin/bash

# For local k3d cluster, we use 127.0.0.1
IP="127.0.0.1"
DOMAINS=("dev.local" "argocd.local" "gitlab.local")
HOSTS_FILE="/etc/hosts"

for domain in "${DOMAINS[@]}"; do
    if ! grep -qE "\s$domain(\s|$)" "$HOSTS_FILE"; then
        echo "Ajout de $domain au fichier hosts"
        echo "$IP    $domain" | sudo tee -a "$HOSTS_FILE" > /dev/null
    else
        echo "$domain est déjà présent dans le fichier hosts"
        # Make sure the IP is correct
        sudo sed -i "s/.*\s$domain/$IP    $domain/" "$HOSTS_FILE"
    fi
done
