#!/bin/bash

IP="192.168.56.110"
DOMAINS=("app1.com" "app2.com" "app3.com")
HOSTS_FILE="/etc/hosts"

for domain in "${DOMAINS[@]}"; do
    if ! grep -qE "\s$domain(\s|$)" "$HOSTS_FILE"; then
        echo "Ajout de $domain au fichier hosts"
        echo "$IP    $domain" | sudo tee -a "$HOSTS_FILE" > /dev/null
    else
        echo "$domain est déjà présent dans le fichier hosts"
    fi
done
