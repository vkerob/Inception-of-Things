#!/bin/bash

set -e

case "$1" in
  --clean)
    bash ./clean_cluster.sh
    ;;
  *)
    # Création du cluster
    bash ./create_cluster.sh

    # Ajout dans /etc/hosts si nécessaire
    if ! grep -q "gitlab.local" /etc/hosts; then
      echo "Ajout de gitlab.local dans /etc/hosts..."
      echo "127.0.0.1 gitlab.local" | sudo tee -a /etc/hosts >/dev/null
    fi

    # Déploiement GitLab
    bash ./install_traefik.sh
    bash ./deploy_gitlab.sh
    bash ./deploy_argocd.sh
    ;;
esac