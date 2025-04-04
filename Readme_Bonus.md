# Bonus: Gitlab integration

## 🎯 Objective

Host a **local GitLab instance**, configure it to work with **K3s/K3d**, and ensure **CI/CD automation** functions correctly within the cluster.  

## 📑 Overview  

- **Deploy GitLab locally** → Run a self-hosted GitLab instance.  
- **Create a `gitlab` namespace** → Isolate GitLab services in Kubernetes.  
- **Integrate GitLab with K3s/K3d** → Allow GitLab to interact with the cluster.  
- **CI/CD with GitLab** → Adapt ArgoCD & GitOps to work with the local GitLab. 

## 📂 Configuration Structure

### `./confs/argocd` → Argo CD Deployment  
- **`argocd-app.yaml`** → Defines the application.  
- **`argocd-ingress.yaml`** → Configures Ingress.  
- **`namespace.yaml`** → Creates the `argocd` namespace.  

### `./confs/dev` → Application Namespace  
- **`namespace.yaml`** → Creates the `dev` namespace.  

### `./confs/gitlab` → GitLab Deployment  
- **`gitlab-ingress.yaml`** → Configures Ingress.  
- **`gitlab-values.yaml`** → gitlab configuration.  ????????????????????????
- **`namespace.yaml`** → Creates the `gitlab` namespace.  

### `./confs/traefik` → Traefik Deployment  
- **`namespace.yaml`** → Creates the `traefik` namespace.  

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
