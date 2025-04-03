#!/bin/bash

set -e

CLUSTER_NAME="cluster-test"

echo "Création du cluster $CLUSTER_NAME si nécessaire..."

if k3d cluster list | grep -q "$CLUSTER_NAME"; then
  echo "Le cluster $CLUSTER_NAME existe déjà."
else
  echo "Création du cluster $CLUSTER_NAME..."
  k3d cluster create "$CLUSTER_NAME" \
    --agents 1 \
    --port "443:443@loadbalancer" \
    --k3s-arg "--disable=traefik@server:0"
fi

echo "Attente que les nœuds soient prêts..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s
echo "Cluster prêt."