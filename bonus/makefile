REQUIREMENTS_FILE_PATH = ./scripts/install_requirement.sh
ADD_TO_HOSTS_PATH = ./scripts/add_to_hosts.sh
CLEAN_CLUSTER_PATH = ./scripts/clean_cluster.sh
CREATE_CERT_PATH = ./scripts/create_cert.sh
CREATE_CLUSTER_PATH = ./scripts/create_cluster.sh
DEPLOY_ARGOCD_PATH = ./scripts/deploy_argocd.sh
INSTALL_TRAEFIK_PATH = ./scripts/install_traefik.sh
DEPLOY_GITLAB_PATH = ./scripts/deploy_gitlab.sh
DEPLOY_REPO_GITLAB_PATH = ./scripts/deploy_repo_gitlab.sh
ARGOCD_NAMESPACE = argocd
DEV_NAMESPACE = dev
GITLAB_NAMESPACE = gitlab
ARGOCD_CONFS_PATH = ./confs/argocd
DEV_CONFS_PATH = ./confs/dev
GITLAB_CONFS_PATH = ./confs/gitlab
URL_ARGOCD = https://argocd.local/
URL_GITLAB = https://gitlab.local/

help:
	@echo "Available commands:"
	@echo "  make help          : Display this help."
	@echo "  make requirements  : Run requirements.sh script to install necessary dependencies."
	@echo "  make k3d           : Create a k3d cluster if it doesn't already exist and create namespaces."
	@echo "  make add_to_hosts  : Add Argo CD URL and dev application to hosts file."
	@echo "  make argocd        : Install Argo CD on the k3d cluster."
	@echo "  make dev           : Create certificate for dev application and deploy the application."
	@echo "  make gitlab        : Install Gitlab on the k3d cluster."
	@echo "  make ingress       : Deploy ingresses for dev application and Argo CD."
	@echo "  make show_id       : Display credentials to connect to Argo CD web interface."
	@echo "  make clean         : Clean the k3d cluster and remove all resources."
	@echo "  make all           : Execute all steps in order: requirements, k3d, argocd, open_port, and show_id."

requirements:
	@echo "Running requirements.sh..."
	@bash $(REQUIREMENTS_FILE_PATH)

k3d:
	@echo "Running create_cluster.sh..."
	@bash $(CREATE_CLUSTER_PATH)
	@echo "Creating namespaces on k3d cluster..."
	@kubectl apply -f $(ARGOCD_CONFS_PATH)/namespace.yaml
	@kubectl apply -f $(DEV_CONFS_PATH)/namespace.yaml
	@kubectl apply -f $(GITLAB_CONFS_PATH)/namespace.yaml
	@echo "Waiting for k3d cluster initialization..."
	@kubectl wait --for=condition=Ready nodes --all --timeout=60s

add_to_hosts:
	@echo "Running add_to_hosts.sh..."
	@bash $(ADD_TO_HOSTS_PATH)

create_cert:
	@echo "Lancement de create_cert.sh..."
	@bash $(CREATE_CERT_PATH)

argocd:
	@echo "Running deploy_argocd.sh..."
	@bash $(DEPLOY_ARGOCD_PATH)
	@echo "Waiting for 'argocd-server' service to be ready..."
	@kubectl rollout status deployment argocd-server -n $(ARGOCD_NAMESPACE) --timeout=120s

dev_app:
	@echo "Creating repository for dev application..."
	@bash $(DEPLOY_REPO_GITLAB_PATH)

dev:
	@echo "Running create_cert_dev.sh..."
	@echo "Deploying dev application..."
	@kubectl apply -f $(ARGOCD_CONFS_PATH)/argocd_app.yaml

gitlab:
	@echo "Running deploy_gitlab.sh..."
	@bash $(DEPLOY_GITLAB_PATH)
	@echo "Waiting for 'gitlab' service to be ready..."
	@kubectl rollout status deployment gitlab-webservice-default -n $(GITLAB_NAMESPACE) --timeout=600s

ingress:
	@echo "Deploying ingresses..."
	@kubectl apply -f $(DEV_CONFS_PATH)/ingress.yaml
	@kubectl apply -f $(ARGOCD_CONFS_PATH)/ingress.yaml
	kubectl apply -f "${GITLAB_CONFS_PATH}/ingress.yaml"

show_id:
	@echo ""
	@echo "Argo CD Web Credentials"
	@echo "URL      : $(URL_ARGOCD)"
	@echo "Username : admin"
	@echo -n "Password :"
	@kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d; echo
	@echo ""
	@echo "Argo CD interface is accessible!"
	@echo "Gitlab Web Credentials"
	@echo "URL      : $(URL_GITLAB)"
	@echo "Username : root"
	@echo -n "Password :"
	@kubectl -n gitlab get secret gitlab-gitlab-initial-root-password \
		-o jsonpath="{.data.password}" | base64 -d; echo
	@echo ""
	@echo "Gitlab interface is accessible!"

clean: 
	@echo "Running clean_cluster.sh..."
	@bash $(CLEAN_CLUSTER_PATH)

all: requirements k3d add_to_hosts create_cert argocd gitlab dev_app dev ingress show_id

re:
	@make clean
	@make all
	@echo "Rebuild complete!"

.PHONY: requirements, k3d, add_to_hosts, create_cert, argocd, dev, gitlab, ingress, show_id, clean, help, all, re