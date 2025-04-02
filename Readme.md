# Inception of Things
42 project - introduction to System Administration

## 📑 Introduction

In collaboration with [vkerob (vkerob)](https://github.com/vkerob), [jvasseur (juliovasseur)](https://github.com/juliovasseur) and [hubourge (hugo-bourgeon)](https://github.com/hugo-bourgeon).

**Inception of Things** is a project that explores container orchestration using **K3d**, **K3s**, **Vagrant**, and **Kubernetes**. The goal is to deploy lightweight **Kubernetes clusters** in a virtualized environment while automating machine management with **Vagrant**.

This project teaches how to **configure a cluster**, **orchestrate services**, and **automate deployments** while adopting a **DevOps** approach. 🚀

<img src="images/subject.png" alt="subject image" width="500"/>

## 🔗 Table of contents

- [Part 1: K3s and Vagrant]()
- [Part 2: K3s and three simple applications]()
- [Part 3: K3d and Argo CD]()
- [Bonus: Gitlab integration]()

## 🚀 Key Concepts  

#### 🛠 Kubernetes  
> **Kubernetes** is an open-source **container orchestration** platform that automates the deployment, management, and scaling of containerized applications. It enables the management of **clusters** running containers efficiently.

#### 🖥️ kubectl  
> **kubectl** is the **command-line tool** for interacting with **Kubernetes clusters**. It allows users to **deploy applications, inspect and manage cluster resources, and troubleshoot issues**.  

#### ⚡ K3s  
> **K3s** is a **lightweight Kubernetes distribution** designed for **fast and easy** deployment. It is optimized for low-resource environments while maintaining Kubernetes compatibility.  

#### 📦 Vagrant  
> **Vagrant** is a tool for **automating** the creation and management of **virtualized environments** using configuration files. It simplifies the deployment process and ensures consistent development environments.  

#### 🐳 K3d  
> **K3d** is a wrapper that allows running **K3s inside Docker containers**, making it easy to set up and simulate a **local Kubernetes cluster** quickly.  

#### 🔄 Continuous Integration & Continuous Delivery (CI/CD)  
> CI/CD is a **DevOps practice** that **automates** the testing and validation of code changes, ensuring faster and more reliable software delivery by reducing manual intervention.  

#### 🔗 Argo CD  
> **Argo CD** is a **GitOps** tool that **automates** the deployment and synchronization of **Kubernetes applications** using a Git repository as the **single source of truth**. It ensures declarative and version-controlled deployments.  


## 🌱 Installation

### Prerequisites
- Virtualbox app ([https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads))
- Ubuntu iso 24.04 LTS ([https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop))

**With the help of a [VirtualBox tutorial](https://wikilibriste.fr/tutoriels/virtualbox ), configure a VM using an Ubuntu ISO with the following specifications :**   
- 6 threads
- 8 GB of Ram
- 20 GB of storage

**Enable Nested Virtualization :**  
- Select VM -> Settings -> System -> Processor -> Enable Nested VT-x/AMD-V

**Enable SSH Communication in the VM :**  
- Select VM -> Settings -> Network -> Adapter 1 -> Attached to -> Bridged Adapter

```sh
sudo apt update && sudo apt install -y openssh-server
sudo systemctl start ssh
sudo ufw allow 22/tcp
sudo ufw allow 22
sudo ufw enable
ip a
```

The bridge is now initialized. To connect, use the username and local IP :
```sh
ssh vboxuser@ip
```

Install packages :
```sh
sudo apt install -y \
	git \
	vim \
	zsh \
	curl \
	wget
	
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update -y && sudo apt install -y vagrant

sudo apt install -y virtualbox
sudo usermod -aG docker vboxuser
sudo usermod -aG sudo vboxuser

wget https://download.virtualbox.org/virtualbox/7.1.6/virtualbox-7.1_7.1.6-167084\~Ubuntu\~noble_amd64.deb
sudo dpkg -i virtualbox-7.1_7.1.6-167084\~Ubuntu\~noble_amd64.deb
```

## 🛰️ Clone project
```sh
git clone git@github.com:vkerob/Inception-of-Things.git
cd Inception-of-Things/
```


## 👨‍🎓 Contributors

- vincent, vkerob [https://github.com/vkerob](https://github.com/vkerob)  
- jules, jvasseur [https://github.com/juliovasseur](https://github.com/juliovasseur)  
- hugo, hubourge [https://github.com/hugo-bourgeon](https://github.com/hugo-bourgeon)