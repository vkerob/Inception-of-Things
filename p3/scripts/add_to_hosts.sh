#!/bin/bash

set -euo pipefail

IP="127.0.0.1"
DOMAINS=("dev.local" "argocd.local")
HOSTS_FILE="/etc/hosts"

for domain in "${DOMAINS[@]}"; do
    if ! grep -qE "\s$domain(\s|$)" "$HOSTS_FILE"; then
        echo "Adding $domain to hosts file"
        echo "$IP    $domain" | sudo tee -a "$HOSTS_FILE" > /dev/null
    else
        echo "$domain already present, updating IP"
        sudo sed -i "s/.*\s$domain\$/$IP    $domain/" "$HOSTS_FILE"
    fi
done