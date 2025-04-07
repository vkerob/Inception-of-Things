# Bonus: Gitlab integration

## 🎯 Objective

Host a **local GitLab instance**, configure it to work with **K3s/K3d**, and ensure **CI/CD automation** functions correctly within the cluster.  

## 📑 Overview  

- **Deploy GitLab locally** → Run a self-hosted GitLab instance.  
- **Create a `gitlab` namespace** → Isolate GitLab services in Kubernetes.  
- **Integrate GitLab with K3s/K3d** → Allow GitLab to interact with the cluster.  
- **CI/CD with GitLab** → Adapt ArgoCD & GitOps to work with the local GitLab. 

> **CI/CD** means continuous integration and continuous delivery/deployment.  

## 📂 Configuration Structure  

### `./confs/argocd` → Argo CD Deployment  
- **`argocd-app.yaml`** → Defines the application.  
	- ➡️ Pulls from GitHub.  
	- ➡️ Deploys to dev namespace.  
	- ➡️ Auto-syncs and removes outdated resources.  

- **`ingress.yaml`** → Configures Ingress.  
	- ➡️ Accessible at `argocd.local`.
	- ➡️ Uses **Traefik** to manage routing.
		> 💡 **Traefik** is a reverse proxy and load balancer for microservices.
	- ➡️ Secure access with `argocd-tls`.
	- ➡️ Forwards requests to `argocd-server` on port `80`.  

- **`namespace.yaml`** → Creates the `argocd` namespace.  
	- ➡️ [What is a namespace ?](#what-is-a-namespace)  

### `./confs/dev` → Application Namespace  
- **`ingress.yaml`** → Configures Ingress. 
	- ➡️ Accessible at `dev.local`.
	- ➡️ Uses **Traefik** to manage routing.
		> 💡 **Traefik** is a reverse proxy and load balancer for microservices.
	- ➡️ Secure access with `argocd-tls`.
	- ➡️ Forwards requests to `argocd-server` on port `8080`.   

- **`namespace.yaml`** → Creates the `dev` namespace.  
	- ➡️ [What is a namespace ?](#what-is-a-namespace)  

### `./confs/gitlab/` → **GitLab Setup**  
- **`gitlab-ingress.yaml`** → Configures Ingress.  
	- ➡️ Accessible at `gitlav.local`.
	- ➡️ Uses **Traefik** to manage routing.
		> 💡 **Traefik** is a reverse proxy and load balancer for microservices.
	- ➡️ Secure access with `argocd-tls`.
	- ➡️ Forwards requests to `argocd-server` on port `8181`.  

- **`gitlab-values.yaml`** → Helm values configuration for GitLab deployment.  
	- ➡️ Sets GitLab components, ports, and resource usage.  
	- ➡️ Customizes deployment (domain, user setup, etc.).  

- **`namespace.yaml`** → Creates the `gitlab` namespace.
	- ➡️ [What is a namespace ?](#what-is-a-namespace)  

### 🏎️ About performance

We used **swap** method to improve performance management during execution.
**Swap** is a **disk space** used when **RAM** is full.

- 🛑 **Prevents crashes** when memory is exhausted.  
- 📦 Temporarily stores **inactive data** from RAM to disk.  
- 🐢 **Much slower** than RAM, since it uses the disk instead of memory.  

## ⌨️ Usefull command

```sh
# Configure and deploy :
# requirements, k3d, argocd, open_port, et show_id
make all 

# Delete cluster
make clean

# List existing namespaces
kubectl get ns

# Check Dev pods
kubectl get pods -n dev

# Check GitLab pods  
kubectl get pods -n gitlab  
```

### 📖 [Home page](https://github.com/vkerob/Inception-of-Things#readme)
