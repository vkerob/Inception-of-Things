#!/bin/bash

set -e

NAMESPACE="gitlab"
GITLAB_CONFS_PATH="../confs/gitlab/"
VALUES_FILE="../confs/gitlab/gitlab-values.yaml"
CHART_REPO="https://charts.gitlab.io/"
RELEASE_NAME="gitlab"

# Vérifie les fichiers requis
if [ ! -f "$VALUES_FILE" ] || [ ! -f "${GITLAB_CONFS_PATH}namespace.yaml" ]; then
  echo "❌ Fichiers $VALUES_FILE ou namespace.yaml manquants."
  exit 1
fi

echo "📁 Création du namespace GitLab depuis namespace.yaml..."
kubectl apply -f ${GITLAB_CONFS_PATH}namespace.yaml

echo "📦 Ajout du repo Helm GitLab..."
helm repo add gitlab "$CHART_REPO"
helm repo update

echo "🚀 Installation de GitLab via Helm..."
helm upgrade --install "$RELEASE_NAME" gitlab/gitlab \
  -n "$NAMESPACE" \
  -f "$VALUES_FILE"

echo "⏳ Attente des pods GitLab (cela peut prendre quelques minutes)..."
kubectl wait --for=condition=Ready pod -l app=webservice -n "$NAMESPACE" --timeout=600s || true

echo "🔐 Récupération du mot de passe root initial..."
PASSWORD=$(kubectl get secret -n "$NAMESPACE" gitlab-gitlab-initial-root-password -ojsonpath="{.data.password}" | base64 -d)
echo "✅ Mot de passe root GitLab : $PASSWORD"

echo "🌐 Accès GitLab : http://localhost"
