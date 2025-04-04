#!/bin/bash

set -euo pipefail

ARGOCD_NAMESPACE="argocd"
ARGOCD_HOSTNAME="argocd.local"
ARGOCD_CONFS_PATH="../confs/argocd/"

kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout argocd.key -out argocd.crt -subj "/CN=argocd.local/O=ArgoCD" >/dev/null 2>&1

kubectl create secret tls argocd-tls \
  --cert=argocd.crt --key=argocd.key \
  -n $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

rm argocd.crt argocd.key

kubectl -n $ARGOCD_NAMESPACE patch deployment argocd-server \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--insecure"}]'