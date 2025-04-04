CLUSTER_NAME = clusterk3d
GITLAB_NAMESPACE = gitlab

.PHONY: all
all:
	@echo "Lancement des prerequis..."
	@if [ ! -d "/home/vboxuser/gitlab-data" ]; then \
		echo "Le répertoire /home/vboxuser/gitlab-data n'existe pas, création en cours..."; \
		mkdir -p /home/vboxuser/gitlab-data; \
	else \
		echo "Le répertoire /home/vboxuser/gitlab-data existe déjà."; \
	fi
	@echo "Lancement cluster k3d..."
	@if k3d cluster list | grep -q "${CLUSTER_NAME}"; then \
		echo "Le cluster ${CLUSTER_NAME} existe déjà"; \
	else \
		echo "Création du cluster '${CLUSTER_NAME}' avec 1 agent..."; \
		k3d cluster create ${CLUSTER_NAME} --agents 1 --volume /home/vboxuser/gitlab-data:/data/gitlab ; \
	fi
	@echo "Attente de l'initialisation du cluster k3d..."
	kubectl wait --for=condition=Ready nodes --all --timeout=60s

	@echo "Création du namespace..."
	kubectl apply -f ./namespace.yaml

	@echo "Déploiement des ressources GitLab..."
	kubectl apply -n $(GITLAB_NAMESPACE) -f ./volume.yaml
	kubectl apply -n $(GITLAB_NAMESPACE) -f ./deployment.yaml
	kubectl apply -n $(GITLAB_NAMESPACE) -f ./service.yaml

	@echo "Attente que le déploiement GitLab soit prêt..."
	kubectl rollout status deployment/gitlab -n $(GITLAB_NAMESPACE) 

	@echo "Lancement du port-forwarding vers GitLab..."
	kubectl port-forward svc/gitlab-svc -n $(GITLAB_NAMESPACE) 8443:80 >/dev/null 2>&1 &




.PHONY: clean
clean: 
	@echo "Suppression du cluster k3d..."
	k3d cluster delete $(CLUSTER_NAME)

	@echo "Nettoyage terminé !"

.PHONY: re
re:
	@make clean
	@make all
	@echo "Reconstruction terminée !"