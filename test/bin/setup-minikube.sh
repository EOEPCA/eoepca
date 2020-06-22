#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

for KUBE_DATA in /mnt/eoepca /data
do
  echo Setting up volume directory: $KUBE_DATA
  sudo mkdir -p $KUBE_DATA
  sudo chmod 777 $KUBE_DATA
done

# minikube: download and install locally
curl -Lo $HOME/.local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x $HOME/.local/bin/minikube

# start minikube
# - default container runtime is docker - see https://minikube.sigs.k8s.io/docs/handbook/config/#runtime-configuration
minikube start --mount --mount-string="/mnt/eoepca:/mnt/eoepca"

# Wait for Kubernetes to be up and ready.
echo "##### Waiting for kubernetes cluster to be ready"
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done
