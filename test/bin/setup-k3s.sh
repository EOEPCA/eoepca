#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

KUBE_DATA="/mnt/eoepca"

mkdir -p $HOME/.local/bin
# cluster data area
sudo mkdir -p $KUBE_DATA
sudo chmod 777 $KUBE_DATA

# install k3s and start
# curl -sfL https://get.k3s.io | sh -s -
# - force use of docker for container runtime (the default is containerd)
curl -sfL https://get.k3s.io | sh -s - --docker
# sudo systemctl enable k3s

# Setup kube config
mkdir -p $HOME/.kube
sudo k3s kubectl config view --raw > $HOME/.kube/config

# Wait for Kubernetes to be up and ready.
echo "##### Waiting for kubernetes cluster to be ready"
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done
