#!/bin/bash
set -euo pipefail

CLUSTER_NAME="clusterk3d"
ARGOCD_CONFS_PATH="../confs/argocd/"
DEV_CONFS_PATH="../confs/dev/"
TRAEFIK_CONFS_PATH="../confs/traefik/"

if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Cluster $CLUSTER_NAME already exists."
else
    echo "Creating cluster $CLUSTER_NAME..."
    k3d cluster create "$CLUSTER_NAME" --port "443:443@loadbalancer"
fi