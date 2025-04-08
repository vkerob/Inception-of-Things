#!/bin/bash

IP="192.168.56.110"
DOMAINS=("app1.com" "app2.com" "app3.com")
HOSTS_FILE="/etc/hosts"

for domain in "${DOMAINS[@]}"; do
    if ! grep -qE "\s$domain(\s|$)" "$HOSTS_FILE"; then
        echo "Adding $domain to hosts file"
        echo "$IP    $domain" | sudo tee -a "$HOSTS_FILE" > /dev/null
    else
        echo "$domain is already present in the hosts file"
    fi
done
