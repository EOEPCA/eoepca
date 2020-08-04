#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

# minikube: download and install locally
echo "Download minikube..."
curl -sLo $HOME/.local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x $HOME/.local/bin/minikube

# minikube (native)
if [ "$1" = "native" ]
then
  if hash conntrack
  then
    # start minikube
    # - default container runtime is docker - see https://minikube.sigs.k8s.io/docs/handbook/config/#runtime-configuration
    echo "Start minikube (native), and wait for cluster..."
    sudo -E $HOME/.local/bin/minikube start --driver=none --addons ingress --wait "all"
    sudo chown -R $USER $HOME/.kube $HOME/.minikube
  else
    echo "ERROR: conntrack must be installed for minikube driver='none', e.g. 'sudo apt install conntrack'. Aborting..."
    exit 1
  fi
# minikube docker
else
  # start minikube
  # - default container runtime is docker - see https://minikube.sigs.k8s.io/docs/handbook/config/#runtime-configuration
  echo "Start minikube (default), and wait for cluster..."
  minikube start --addons ingress --wait "all"
fi

echo "...READY"
