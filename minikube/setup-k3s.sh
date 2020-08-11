#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

# install k3s and start
# curl -sfL https://get.k3s.io | sh -s -
# - fix to specific release
# - force use of docker for container runtime (the default is containerd)
# - disable traefik, to be replaced ingress-nginx
export INSTALL_K3S_VERSION="v1.18.6+k3s1"
curl -sfL https://get.k3s.io | sh -s - --docker --disable traefik
# sudo systemctl enable k3s

# Setup kube config
mkdir -p $HOME/.kube
sudo k3s kubectl config view --raw > $HOME/.kube/config

# Wait for Kubernetes to be up and ready.
echo "[INFO]  Waiting for kubernetes cluster to be ready..."
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'
until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done
echo "[INFO]  ...kubernetes cluster is ready."

# Deploy nginx ingress controller
echo "[INFO]  Deploy ingress-nginx..."
kubectl apply -f ../kubernetes/ingress-controller/deploy-cloud.yaml >/dev/null
echo "[INFO]  ...ingress-nginx DEPLOYED."
# The first time the ingress controller starts, two Jobs create the SSL Certificate used by the admission webhook.
# For this reason, there is an initial delay of up to two minutes until it is possible to create and validate Ingress definitions.
echo "[INFO]  Wait for ingress-nginx ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo "[INFO]  ...ingress-nginx READY."
