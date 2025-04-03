#!/bin/bash

set -e

./install_requirement.sh
./create_cluster.sh
./create_namespace.sh
./install_traefik.sh
./add_to_hosts.sh
./create_cert_dev.sh
./deploy_argocd.sh
./deploy_ingress.sh

