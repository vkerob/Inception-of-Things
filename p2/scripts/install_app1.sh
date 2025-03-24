sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Attendre que le serveur K3s soit opérationnel (optionnel : ajustez la durée si besoin)
SERVER="https://192.168.56.110:6443"
TIMEOUT=60
while ! curl -k --silent --output /dev/null --connect-timeout 5 "$SERVER"; do
    sleep 2
    TIMEOUT=$((TIMEOUT - 2))
    if [ "$TIMEOUT" -le 0 ]; then
        echo "Erreur : Le serveur K3s ne répond pas après 60 secondes."
        exit 1
    fi
done

echo "Déploiement de app1 via kubectl..."
# Appliquer les fichiers de déploiement et de service
# kubectl create configmap app1-config --from-file=/vagrant/confs/app1/app1.html
kubectl apply -f /vagrant/confs/app1/service.yaml
kubectl apply -f /vagrant/confs/app1/deployment.yaml

kubectl apply -f /vagrant/confs/ingress.yaml