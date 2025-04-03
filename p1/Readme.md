# Part 1: K3s and Vagrant

## 🎯 Objective
Objective
In this part, we need to set up two virtual machines using **Vagrant**. These machines will run **K3s** to form a Kubernetes cluster with one node as the controller and the other as the worker.

## 📑 Overview

1. **Vagrantfile** setup with:

	- Linux OS distribution, here: `bento/debian-12`

	- **1 CPU** and **512 MB of RAM** minimum

	- Two machines with specific names:

		- The first machine: **jvasseurS** (IP: 192.168.56.110).

		- The second machine: **jvasseurSW** (IP: 192.168.56.111).

2. **SSH** access between the machines without password prompts.

3. Install **K3s** and **kubectl**:

	- On Server, install K3s in **controller mode**. (`CONFIG_SRC="/vagrant/confs/config-server.yaml"`)

	- On ServerWorker, install K3s in **agent mode**. (`CONFIG_SRC="/vagrant/confs/config-agent.yaml"`)  

> Expected virtual machines
> ![virtualbox](/images/p1_virtualbox.png)

## ⚡ K3s modes

- **Server Mode (Controller Mode)**  
	>  Manages the API, schedules pods, stores data.  
  Works alone or with multiple servers.  

- **Agent Mode (Worker Mode)**  
	>  Runs workloads (containers).  
  Follows server instructions (assigned tasks, retrieves configurations).  

- **Embedded Mode**  
	>  K3s runs standalone, without a central server.  
  Ideal for local testing.  

- **HA Mode (High Availability)**  
	>  Multiple servers for fault tolerance.  
  Requires an external data store (MySQL, PostgreSQL, etcd).  

- **Air-Gap Mode**  
	>  Installation without Internet.  
  Pre-downloaded dependencies.  


## ⌨️ Usefull command

```sh
# Start the machines
vagrant up

# SSH connection to a machine
vagrant ssh jvasseurS
vagrant ssh jvasseurSW

# Show local IP informations
ip a show eth1

# Show all objects on cluster
kubectl get all

# Show nodes on cluster
kubectl get nodes -o wide

# Destroy the machines to reset everything
vagrant destroy -f
```

### 📖 [Home page](https://github.com/vkerob/Inception-of-Things#readme)