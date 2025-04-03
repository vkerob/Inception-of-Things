#!/bin/bash

set -e

ARGOCD_NAMESPACE="argocd"
ARGOCD_CONFS_PATH="../confs/argocd/"
ARGOCD_HOSTNAME="argocd.local"

echo "Installation d'ArgoCD..."

# Création du namespace argocd si nécessaire
kubectl apply -f "${ARGOCD_CONFS_PATH}namespace.yaml"

# Déploiement d'ArgoCD
echo "Déploiement d'ArgoCD (manifests)..."
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Patch pour désactiver la redirection HTTPS côté Argo CD (Traefik gère déjà TLS)
echo "🔧 Ajout du flag --insecure à argocd-server..."
kubectl -n $ARGOCD_NAMESPACE patch deployment argocd-server \
  --type='json' \
  -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/args/-",
      "value": "--insecure"
    }
  ]'

# Attente que le serveur soit prêt
echo "Attente que 'argocd-server' soit prêt..."
kubectl rollout status deployment argocd-server -n $ARGOCD_NAMESPACE --timeout=120s

# Application de l'Ingress Traefik pour ArgoCD
echo "Déploiement de l'Ingress Traefik pour Argo CD..."
kubectl apply -f "${ARGOCD_CONFS_PATH}argocd-ingress.yaml"

# Déploiement de l'application ArgoCD (si applicable)
kubectl apply -n $ARGOCD_NAMESPACE -f "${ARGOCD_CONFS_PATH}argocd-app.yaml"

# Ajout dans /etc/hosts si nécessaire
if ! grep -q "$ARGOCD_HOSTNAME" /etc/hosts; then
  echo "Ajout de $ARGOCD_HOSTNAME dans /etc/hosts..."
  echo "127.0.0.1 $ARGOCD_HOSTNAME" | sudo tee -a /etc/hosts >/dev/null
fi

# Affichage des identifiants
echo ""
echo "Identifiants ArgoCD Web"
echo "URL : https://$ARGOCD_HOSTNAME"
echo "Utilisateur : admin"
echo "Mot de passe :"
kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d; echo