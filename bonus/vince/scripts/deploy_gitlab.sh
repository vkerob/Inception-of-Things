#!/bin/bash
set -e

GITLAB_NS="gitlab"
CHART_REPO="https://charts.gitlab.io/"
GITLAB_CONFS_PATH="confs/gitlab"
VALUES_FILE="${GITLAB_CONFS_PATH}/gitlab_values.yaml"
RELEASE_NAME="gitlab"


echo "==> Création certificat TLS auto-signé..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt -subj "/CN=gitlab.local/O=GitLab" >/dev/null 2>&1
kubectl create secret tls gitlab-tls \
  --cert=tls.crt --key=tls.key \
  -n "$GITLAB_NS" --dry-run=client -o yaml | kubectl apply -f -
rm tls.crt tls.key

echo "==> Installation de GitLab via Helm..."
helm repo add gitlab "$CHART_REPO" || true
helm repo update
helm upgrade --install "$RELEASE_NAME" gitlab/gitlab \
  -n "$GITLAB_NS" \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set global.shell.enabled=false \
  -f "$VALUES_FILE" \
  --timeout 30m
