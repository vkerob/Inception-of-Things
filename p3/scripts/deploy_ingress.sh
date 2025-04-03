#!/bin/bash

echo "Déploiement des ingress"
kubectl apply -f ../confs/dev/ingress.yaml
kubectl apply -f ../confs/argocd/ingress.yaml