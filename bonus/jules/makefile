REQUIREMENTS_FILE_PATH = ./scripts/install_requirement.sh
ARGOCD_NAMESPACE = argocd
K3D_CMD = k3d
CLUSTER_NAME = clusterk3d
URL_ARGOCD = https://localhost:8080/
DEV_NAMESPACE = dev

.PHONY: help
help:
	@echo "Commandes disponibles :"
	@echo "  make help          : Affiche cette aide."
	@echo "  make requirements  : Exécute le script requirements.sh pour installer les dépendances nécessaires."
	@echo "  make k3d           : Crée un cluster k3d si celui-ci n'existe pas déjà."
	@echo "  make argocd        : Installe Argo CD sur le cluster k3d."
	@echo "  make open_port     : Ouvre le port 8080 pour accéder à l'interface web d'Argo CD."
	@echo "  make show_id       : Affiche les identifiants pour se connecter à l'interface web d'Argo CD."
	@echo "  make all           : Exécute toutes les étapes dans l'ordre : requirements, k3d, argocd, open_port, et show_id."

.PHONY: requirements
requirements:
	@echo "Lancement de requirements.sh..."
	@bash $(REQUIREMENTS_FILE_PATH)

.PHONY: k3d
k3d:
	@echo "Lancement cluster k3d..."
	@if k3d cluster list | grep -q "${CLUSTER_NAME}"; then \
		echo "Le cluster ${CLUSTER_NAME} existe déjà"; \
	else \
		echo "Création du cluster '${CLUSTER_NAME}' avec 1 agent..."; \
		k3d cluster create ${CLUSTER_NAME} --agents 1; \
	fi
	@echo "Attente de l'initialisation du cluster k3d..."
	kubectl wait --for=condition=Ready nodes --all --timeout=60s

	@echo "Création des namespaces sur le cluster k3d.."
	kubectl apply -f ./confs/argocd/namespace.yaml
	kubectl apply -f ./confs/dev/namespace.yaml

.PHONY: argocd
argocd:
	@echo "Lancement d'argocd sur le cluster k3d..."
	@if kubectl get pods -n argocd | grep -q "argocd-server"; then \
		echo "Le serveur argocd est déjà en cours d'exécution"; \
	else \
		echo "Installation d'argocd..."; \
		kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml; \
	fi
	@echo "Attente que le service 'argocd-server' soit prêt..."
	kubectl rollout status deployment argocd-server -n $(ARGOCD_NAMESPACE) --timeout=120s


.PHONY: open_port
open_port:
	@echo "Port forwarding argocd sur https://localhost:8080..."
	kubectl port-forward svc/argocd-server -n $(ARGOCD_NAMESPACE) 8080:80 >/dev/null 2>&1 &
	@echo "Vérification et port forwarding de l'app dev..."
	@echo "Vérification du service svc-wil dans le namespace dev..."
	@while [ -z "$$(kubectl get endpoints svc-wil -n dev -o jsonpath='{.subsets[*].addresses}')" ]; do \
		echo "En attente que svc-wil soit disponible..."; \
		sleep 5; \
	done
	@echo "svc-wil est prêt !"
	kubectl port-forward svc/svc-wil -n $(DEV_NAMESPACE) 8888:8080 >/dev/null 2>&1 & 

.PHONY: show_id
show_id:
	@echo ""
	@echo "Identifiants Argo CD Web"
	@echo "URL      : $(URL_ARGOCD)"
	@echo "Utilisateur : admin"
	kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d; echo
	@echo ""
	@echo "L'interface Argo CD est accessible !"


.PHONY: dev
dev:
	@echo "Lancement de l app dev"
	kubectl apply -n $(ARGOCD_NAMESPACE) -f ./confs/argocd/argocd-app.yaml


.PHONY: clean
clean: 
	@echo "Suppression du cluster k3d..."
	k3d cluster delete $(CLUSTER_NAME)

	@echo "Nettoyage terminé !"


.PHONY: all
all: requirements k3d argocd dev open_port show_id 


.PHONY: re
re:
	@make clean
	@make all
	@echo "Reconstruction terminée !"