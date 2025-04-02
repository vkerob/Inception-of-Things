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

kubectl create configmap app1-html --from-file=/vagrant/confs/app1/index.html
kubectl apply -f /vagrant/confs/app1/service.yaml
kubectl apply -f /vagrant/confs/app1/deployment.yaml

kubectl apply -f /vagrant/confs/ingress.yaml

echo "Déploiement de app2 via kubectl..."

kubectl create configmap app2-html --from-file=/vagrant/confs/app2/index.html
kubectl apply -f /vagrant/confs/app2/service.yaml
kubectl apply -f /vagrant/confs/app2/deployment.yaml

kubectl apply -f /vagrant/confs/ingress.yaml

echo "Déploiement de app3 via kubectl..."

kubectl create configmap app3-html --from-file=/vagrant/confs/app3/index.html
kubectl apply -f /vagrant/confs/app3/service.yaml
kubectl apply -f /vagrant/confs/app3/deployment.yaml

kubectl apply -f /vagrant/confs/ingress.yaml