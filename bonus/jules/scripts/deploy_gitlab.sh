#!/bin/bash
set -e

GITLAB_NS="gitlab"
GITLAB_NAMESPACE="gitlab"

echo "==> Création certificat TLS auto-signé..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout gitlab.key -out gitlab.crt -subj "/CN=gitlab.local/O=GitLab" >/dev/null 2>&1
kubectl create secret tls gitlab-tls \
  --cert=gitlab.crt --key=gitlab.key \
  -n "$GITLAB_NS" --dry-run=client -o yaml | kubectl apply -f -
rm gitlab.crt gitlab.key


kubectl apply -n $GITLAB_NAMESPACE -f ./confs/gitlab/volume.yaml
kubectl apply -n $GITLAB_NAMESPACE -f ./confs/gitlab/deployment.yaml
kubectl apply -n $GITLAB_NAMESPACE -f ./confs/gitlab/service.yaml