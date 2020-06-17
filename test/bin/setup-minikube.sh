#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

KUBE_DATA="/mnt/eoepca"

mkdir -p $HOME/.local/bin
# cluster data area
mkdir -p $KUBE_DATA

# cluster data area
sudo mkdir -p $KUBE_DATA
sudo chmod 777 $KUBE_DATA

# minikube: download and install locally
curl -Lo $HOME/.local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x $HOME/.local/bin/minikube

# start minikube
# - default container runtime is docker - see https://minikube.sigs.k8s.io/docs/handbook/config/#runtime-configuration
minikube start --mount --mount-string="$KUBE_DATA:/mnt/eoepca"
