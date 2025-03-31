#!/bin/bash

set -e

CLUSTER_NAME="cluster-test"
ARGOCD_NAMESPACE="argocd"
ARGOCD_CONFS_PATH="../confs/argocd/"
DEV_CONFS_PATH="../confs/dev/"

echo "Initialisation du cluster K3D + Argo CD"

# === 1. Création du cluster k3d ===
if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "Le cluster $CLUSTER_NAME existe déjà"
else
    echo "Création du cluster '$CLUSTER_NAME' avec 1 agent..."
    k3d cluster create "$CLUSTER_NAME" --agents 1
fi

# === 2. Attente que tous les nœuds soient prêts ===
echo "Attente que les nœuds soient prêts..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s


# === 4. Création des namespaces ===
echo "Création des namespaces 'argocd' et 'dev'..."
kubectl apply -f ${ARGOCD_CONFS_PATH}namespace.yaml

kubectl apply -f ${DEV_CONFS_PATH}namespace.yaml

# === 5. Déploiement d'Argo CD ===
echo "Déploiement d'Argo CD (manifests)..."
kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# === 6. Attente que le déploiement soit prêt ===
echo "Attente que 'argocd-server' soit prêt..."
kubectl rollout status deployment argocd-server -n $ARGOCD_NAMESPACE --timeout=120s

kubectl apply -n $ARGOCD_NAMESPACE -f ${ARGOCD_CONFS_PATH}argocd-app.yaml


# === 11. Affichage des identifiants ===
echo ""
echo "Identifiants Argo CD Web"
echo "URL : http://localhost:8080"
echo "Utilisateur : admin"
echo "Mot de passe :"
kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d; echo

# Récupération du mot de passe Argo CD
ARGOCD_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d)

# Port forwarding sur http://localhost:8080...
echo "Port forwarding sur http://localhost:8080..."
kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:80 >/dev/null 2>&1 &


echo ""
echo "L'interface Argo CD est accessible !"
