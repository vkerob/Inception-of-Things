#!/bin/bash

ARGOCD_CONFS_PATH="../confs/argocd/"
DEV_CONFS_PATH="../confs/dev/"

# Création du namespace argocd si nécessaire
kubectl apply -f "${ARGOCD_CONFS_PATH}namespace.yaml"

# Création du namespace dev si nécessaire
kubectl apply -f "${DEV_CONFS_PATH}namespace.yaml"