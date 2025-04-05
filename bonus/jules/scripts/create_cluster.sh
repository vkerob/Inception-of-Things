#!/bin/bash
set -euo pipefail

CLUSTER_NAME="clusterk3d"
ARGOCD_CONFS_PATH="../confs/argocd/"
DEV_CONFS_PATH="../confs/dev/"
TRAEFIK_CONFS_PATH="../confs/traefik/"


if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Le cluster $CLUSTER_NAME existe déjà."
else
    echo "Création du cluster $CLUSTER_NAME..."
    k3d cluster create "$CLUSTER_NAME" --agents 2 \
    --port "443:443@loadbalancer" \
    --k3s-arg "--kubelet-arg=eviction-hard=imagefs.available<1%,nodefs.available<1%@all" \
    --k3s-arg "--kubelet-arg=eviction-minimum-reclaim=imagefs.available=1%,nodefs.available=1%@all" \
    --servers-memory "4GB" \
    --agents-memory "4GB"
fi
