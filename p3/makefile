REQUIREMENTS_FILE_PATH = ./scripts/install_requirement.sh
ADD_TO_HOSTS_PATH = ./scripts/add_to_hosts.sh
CLEAN_CLUSTER_PATH = ./scripts/clean_cluster.sh
CREATE_CERT_DEV_PATH = ./scripts/create_cert_dev.sh
CREATE_CLUSTER_PATH = ./scripts/create_cluster.sh
DEPLOY_ARGOCD_PATH = ./scripts/deploy_argocd.sh
INSTALL_TRAEFIK_PATH = ./scripts/install_traefik.sh
ARGOCD_NAMESPACE = argocd
DEV_NAMESPACE = dev
ARGOCD_CONFS_PATH = ./confs/argocd
DEV_CONFS_PATH = ./confs/dev
URL_ARGOCD = https://argocd.local/

help:
	@echo "Commandes disponibles :"
	@echo "  make help          : Affiche cette aide."
	@echo "  make requirements  : Exécute le script requirements.sh pour installer les dépendances nécessaires."
	@echo "  make k3d           : Crée un cluster k3d si celui-ci n'existe pas déjà et crée les namespaces."
	@echo "  make add_to_hosts : Ajoute l'URL d'Argo CD et de l'application dev au fichier hosts."
	@echo "  make argocd        : Installe Argo CD sur le cluster k3d."
	@echo "  make dev          : Créer le certificat pour l'application dev et déploi l'application."
	@echo "  make ingress      : Déploie les ingress pour l'application dev et Argo CD."
	@echo "  make show_id       : Affiche les identifiants pour se connecter à l'interface web d'Argo CD."
	@echo "  make all           : Exécute toutes les étapes dans l'ordre : requirements, k3d, argocd, open_port, et show_id."

requirements:
	@echo "Lancement de requirements.sh..."
	@bash $(REQUIREMENTS_FILE_PATH)

k3d:
	@echo "Lancement de create_cluster.sh..."
	@bash $(CREATE_CLUSTER_PATH)
	@echo "Création des namespaces sur le cluster k3d.."
	@kubectl apply -f $(ARGOCD_CONFS_PATH)/namespace.yaml
	@kubectl apply -f $(DEV_CONF_PATH)/namespace.yaml
	@echo "Attente de l'initialisation du cluster k3d..."
	@kubectl wait --for=condition=Ready nodes --all --timeout=60s

add_to_hosts:
	@echo "Lancement de add_to_hosts.sh..."
	@bash $(ADD_TO_HOSTS_PATH)

argocd:
	@echo "Lancement de deploy_argocd.sh..."
	@bash $(DEPLOY_ARGOCD_PATH)
	@echo "Attente que le service 'argocd-server' soit prêt..."
	@kubectl rollout status deployment argocd-server -n $(ARGOCD_NAMESPACE) --timeout=120s

dev:
	@echo "Lancement de create_cert_dev.sh..."
	@bash $(CREATE_CERT_DEV_PATH)
	@echo "Déploiement de l'application dev..."
	@kubectl apply -f $(ARGOCD_CONFS_PATH)/argocd_app.yaml

ingress:
	@echo "Déploiement des ingress..."
	@kubectl apply -f $(DEV_CONFS_PATH)/ingress.yaml
	@kubectl apply -f $(ARGOCD_CONFS_PATH)/ingress.yaml

show_id:
	@echo ""
	@echo "Identifiants Argo CD Web"
	@echo "URL      : $(URL_ARGOCD)"
	@echo "Utilisateur : admin"
	kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d; echo
	@echo ""
	@echo "L'interface Argo CD est accessible !"

clean: 
	@echo "lancement de clean_cluster.sh..."
	@bash $(CLEAN_CLUSTER_PATH)

all: requirements k3d add_to_hosts argocd dev ingress show_id help

re:
	@make clean
	@make all
	@echo "Reconstruction terminée !"

.PHONY: requirements,k3d, add_to_hosts, argocd, dev, ingress, show_id, clean, help, all, re