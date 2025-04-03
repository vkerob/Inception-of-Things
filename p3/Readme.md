# Part 3: K3d and Argo CD

## 🎯 Objective
In this part of the project, the goal is to set up **K3d**, **Argo CD**, and implement **continuous integration** to automate the deployment of an application.

**Argo CD** is a GitOps tool that automates the deployment of applications in Kubernetes clusters.

## 📑 Overview

- 1️⃣ **K3d Setup**:  
   - Install **K3d**.

	> #### Difference Between K3s and K3d ?
	> - **K3s** is a lightweight Kubernetes distribution, optimized for resource-constrained environments.
	> - **K3d** provides an easier way to run **K3s** within Docker containers, allowing users to simulate Kubernetes clusters locally.

- 2️⃣ **Argo CD Setup**:  
   - Create two namespaces: **argocd** (for Argo CD) and **dev** (for your app).

	> #### What is a namespace ?
	> A **namespace** in Kubernetes **isolates resources within a cluster** to organize and separate resources from applications or environments (like dev, argocd).

- 3️⃣ **GitHub Repo**:  
   - Setup a public GitHub repository and push configuration files.
   - [https://github.com/vkerob/vkerob-IoT-Part3](https://github.com/vkerob/vkerob-IoT-Part3)

- 4️⃣ **Docker Image**:  
   - Use Wil’s pre-built app.
   - [https://hub.docker.com/r/wil42/playground](https://hub.docker.com/r/wil42/playground)

- 5️⃣ **Continuous Deployment**:  
   - **Argo CD** will automatically deploy the app from GitHub whenever changes are made.

	> #### What is Argo CD ?  
	> **Argo CD** is a **GitOps** tool that **automates** the deployment and synchronization of **Kubernetes applications** using a Git repository as the **single source of truth**. It ensures declarative and version-controlled deployments.  

---

### 🏗️ Illustrations


> <img src="../images/p3_argocd.png" alt="subject image" width="450"/>  

> Diagram about global infrastructure    

> <img src="../images/p3_argocd_app.png" alt="subject image" width="800"/>  

> Argocd application  

> <img src="../images/p3_dev_app.png" alt="subject image" width="450"/>  

> Dev app deploy at `http://localhost:8888`

## ⌨️ Usefull command

```sh
# On utilise le makefile ou les script ?

# Configure and deploy :
# requirements, k3d, argocd, open_port, et show_id
make all 

# Delete cluster
make clean

# List existing namespaces
kubectl get ns

# Show deployed pods in the "dev" namespace
kubectl get pods -n dev
```

### 📖 [Home page](https://github.com/vkerob/Inception-of-Things#readme)
