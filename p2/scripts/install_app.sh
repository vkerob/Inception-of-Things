# Wait for K3s server to be operational (optional: adjust duration if needed)
SERVER="https://192.168.56.110:6443"
TIMEOUT=60
while ! curl -k --silent --output /dev/null --connect-timeout 5 "$SERVER"; do
    sleep 2
    TIMEOUT=$((TIMEOUT - 2))
    if [ "$TIMEOUT" -le 0 ]; then
        echo "Error: K3s server is not responding after 60 seconds."
        exit 1
    fi
done

echo "Deploying app1 via kubectl..."

kubectl create configmap app1-html --from-file=/vagrant/confs/app1/index.html
kubectl apply -f /vagrant/confs/app1/service.yaml
kubectl apply -f /vagrant/confs/app1/deployment.yaml

kubectl apply -f /vagrant/confs/ingress.yaml

echo "Deploying app2 via kubectl..."

kubectl create configmap app2-html --from-file=/vagrant/confs/app2/index.html
kubectl apply -f /vagrant/confs/app2/service.yaml
kubectl apply -f /vagrant/confs/app2/deployment.yaml

kubectl apply -f /vagrant/confs/ingress.yaml

echo "Deploying app3 via kubectl..."

kubectl create configmap app3-html --from-file=/vagrant/confs/app3/index.html
kubectl apply -f /vagrant/confs/app3/service.yaml
kubectl apply -f /vagrant/confs/app3/deployment.yaml

kubectl apply -f /vagrant/confs/ingress.yaml