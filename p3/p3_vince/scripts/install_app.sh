#!/bin/bash

set -e

CLUSTER_NAME="cluster-test"
ARGOCD_NAMESPACE="argocd"

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

# === 3. Déploiement d'Argo CD ===
if kubectl get ns | grep -q "$ARGOCD_NAMESPACE"; then
    echo "Le namespace '$ARGOCD_NAMESPACE' existe déjà"
else
    echo "Déploiement d'Argo CD..."
    kubectl create namespace $ARGOCD_NAMESPACE
    kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
fi

# === 4. Attente que le service Argo CD soit accessible ===
echo "Attente que le service 'argocd-server' soit prêt..."
kubectl rollout status deployment argocd-server -n $ARGOCD_NAMESPACE --timeout=120s

# === 5. Lancement du port-forward obligatoire ===
echo "Lancement du port-forward sur http://localhost:8080 ..."
echo "Ce terminal sera bloqué tant que le port-forward est actif. Ouvre un nouvel onglet pour continuer."

kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443 &
sleep 3

# === 6. Affichage des identifiants ===
echo ""
echo "Identifiants Argo CD Web"
echo "URL      : https://localhost:8080"
echo "Utilisateur : admin"
echo "Mot de passe :"
kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d; echo

echo ""
echo "L'interface Argo CD est accessible ! Laisse ce terminal ouvert tant que tu veux y accéder."
