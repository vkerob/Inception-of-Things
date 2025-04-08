
#!/bin/bash
set -euo pipefail

DEV_NAMESPACE="dev"
GITLAB_NAMESPACE="gitlab"
ARGOCD_NAMESPACE="argocd"


echo "==> Creating self-signed TLS certificate for  $ARGOCD_NAMESPACE..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout argocd.key -out argocd.crt -subj "/CN=argocd.local/O=ArgoCD" >/dev/null 2>&1
kubectl create secret tls argocd-tls \
  --cert=argocd.crt --key=argocd.key \
  -n $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
rm argocd.crt argocd.key


echo "==> Creating self-signed TLS certificate for $GITLAB_NAMESPACE..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt -subj "/CN=gitlab.local/O=GitLab" >/dev/null 2>&1
kubectl create secret tls gitlab-tls \
  --cert=tls.crt --key=tls.key \
  -n "$GITLAB_NS" --dry-run=client -o yaml | kubectl apply -f -
rm tls.crt tls.key


echo "==> Creating self-signed TLS certificate for  $DEV_NAMESPACE..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout wil.key -out wil.crt -subj "/CN=dev.local/O=Dev" >/dev/null 2>&1
kubectl create secret tls wil-tls \
  --cert=wil.crt --key=wil.key \
  -n $DEV_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
rm wil.crt wil.key

