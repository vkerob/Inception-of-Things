#!/bin/bash

set -e

ARGOCD_NAMESPACE="argocd"
ARGOCD_CONFS_PATH="../confs/argocd/"
ARGOCD_HOSTNAME="argocd.local"

echo "Installation d'ArgoCD..."

# Déploiement d'ArgoCD
echo "Déploiement d'ArgoCD (manifests)..."
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Create TLS certificate for ArgoCD
echo "Création du certificat TLS pour ArgoCD..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout argocd.key -out argocd.crt -subj "/CN=argocd.local/O=ArgoCD" >/dev/null 2>&1

kubectl create secret tls argocd-tls \
  --cert=argocd.crt --key=argocd.key \
  -n $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

rm argocd.crt argocd.key

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


# Déploiement de l'application ArgoCD (si applicable)
kubectl apply -n $ARGOCD_NAMESPACE -f "${ARGOCD_CONFS_PATH}argocd-app.yaml"

# Affichage des identifiants
echo ""
echo "Identifiants ArgoCD Web"
echo "URL : https://$ARGOCD_HOSTNAME"
echo "Utilisateur : admin"
echo "Mot de passe :"
kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d; echo