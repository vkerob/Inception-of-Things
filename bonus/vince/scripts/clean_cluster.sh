#!/bin/bash

set -euo pipefail

CLUSTER_NAME="clusterk3d"
DEV_NAMESPACE="dev"
GITLAB_NAMESPACE="gitlab"
ARGOCD_NAMESPACE="argocd"
HOSTS_FILE="/etc/hosts"
DOMAINS=("dev.local" "argocd.local" "gitlab.local")

echo "Nettoyage en cours..."

# Suppression des entrées dans /etc/hosts
echo "Vérification et suppression des entrées dans $HOSTS_FILE..."
for domain in "${DOMAINS[@]}"; do
    if grep -qE "\s$domain(\s|$)" "$HOSTS_FILE"; then
        echo "Suppression de $domain du fichier hosts"
        sudo sed -i "/\s$domain(\s|$)/d" "$HOSTS_FILE"
    else
        echo "$domain n'est pas présent dans le fichier hosts"
    fi
done

# Vérification et suppression du cluster
if k3d cluster list 2>/dev/null | grep -q "$CLUSTER_NAME"; then
  echo "Suppression du cluster $CLUSTER_NAME..."
  k3d cluster delete "$CLUSTER_NAME"
else
  echo "Le cluster $CLUSTER_NAME n'existe pas, rien à supprimer."
fi

