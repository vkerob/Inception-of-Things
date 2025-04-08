#!/bin/bash
set -e

GITLAB_NS="gitlab"
CHART_REPO="https://charts.gitlab.io/"
GITLAB_CONFS_PATH="confs/gitlab"
VALUES_FILE="${GITLAB_CONFS_PATH}/gitlab_values.yaml"
RELEASE_NAME="gitlab"

echo "==> Installation de GitLab via Helm..."
helm repo add gitlab "$CHART_REPO" || true
helm repo update
helm upgrade --install "$RELEASE_NAME" gitlab/gitlab \
  -n "$GITLAB_NS" \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  -f "$VALUES_FILE" \
  --timeout 30m
