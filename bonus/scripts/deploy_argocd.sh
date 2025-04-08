#!/bin/bash

set -euo pipefail

ARGOCD_NAMESPACE="argocd"
ARGOCD_HOSTNAME="argocd.local"
ARGOCD_CONFS_PATH="../confs/argocd/"

kubectl apply -n $ARGOCD_NAMESPACE -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl -n $ARGOCD_NAMESPACE patch deployment argocd-server \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--insecure"}]'