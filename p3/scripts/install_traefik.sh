#!/bin/bash
set -e

# Namespace Traefik
TRAEFIK_NS="traefik"
mkdir -p ../confs/traefik

# Création du namespace
kubectl apply -f ../confs/traefik/namespace.yaml

# Installation Traefik
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm upgrade --install traefik traefik/traefik \
  --namespace "$TRAEFIK_NS" \
  --set service.type=LoadBalancer \
  --set ingressClass.enabled=true \
  --set ingressClass.isDefaultClass=true


