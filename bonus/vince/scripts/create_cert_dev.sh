
#!/bin/bash
set -euo pipefail

DEV_NAMESPACE="dev"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout wil.key -out wil.crt -subj "/CN=dev.local/O=Dev" >/dev/null 2>&1

kubectl create secret tls wil-tls \
  --cert=wil.crt --key=wil.key \
  -n $DEV_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

rm wil.crt wil.key