#!/bin/bash

set -euo pipefail

CLUSTER_NAME="clusterk3d"
DEV_NAMESPACE="dev"
GITLAB_NAMESPACE="gitlab"
ARGOCD_NAMESPACE="argocd"
HOSTS_FILE="/etc/hosts"
DOMAINS=("dev.local" "argocd.local" "gitlab.local")

echo "Cleaning in progress..."

# Remove entries from /etc/hosts
echo "Checking and removing entries from $HOSTS_FILE..."
for domain in "${DOMAINS[@]}"; do
    if grep -qE "\s$domain(\s|$)" "$HOSTS_FILE"; then
        echo "Removing $domain from hosts file"
        sudo sed -i "/\s$domain(\s|$)/d" "$HOSTS_FILE"
    else
        echo "$domain is not present in the hosts file"
    fi
done

# Check and delete cluster
if k3d cluster list 2>/dev/null | grep -q "$CLUSTER_NAME"; then
  echo "Deleting cluster $CLUSTER_NAME..."
  k3d cluster delete "$CLUSTER_NAME"
else
  echo "Cluster $CLUSTER_NAME does not exist, nothing to delete."
fi

