#!/bin/bash

CLUSTER_NAME="cluster-test"
DEV_NAMESPACE="dev"
GITLAB_NAMESPACE="gitlab"
ARGOCD_NAMESPACE="argocd"

echo "Nettoyage en cours..."

# Suppression des entrées dans /etc/hosts
if grep -q "gitlab.local\|argocd.local" /etc/hosts; then
  echo "Suppression des entrées dans /etc/hosts..."
  sudo sed -i '/gitlab.local/d' /etc/hosts
  sudo sed -i '/argocd.local/d' /etc/hosts
fi

# Vérification et suppression du cluster
if k3d cluster list 2>/dev/null | grep -q "$CLUSTER_NAME"; then
  echo "Suppression du cluster $CLUSTER_NAME..."
  k3d cluster delete "$CLUSTER_NAME"
else
  echo "Le cluster $CLUSTER_NAME n'existe pas, rien à supprimer."
fi

