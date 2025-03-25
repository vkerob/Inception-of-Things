#!/bin/bash


echo "Création des namespaces..."
kubectl create -f /vagrant/confs/namespaces.yaml

echo "Déploiement de Nginx sur le namespace dev..."
kubectl apply -f /vagrant/confs/deployment.yaml

echo "Installation d'ArgoCD sur le namespace argocd..."
kubectl apply -n argocd -f /vagrant/confs/argocd-install.yaml





echo "Déploiement terminé !"
