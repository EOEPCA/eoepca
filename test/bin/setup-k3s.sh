#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# cluster data area
mkdir -p /tmp/eoepca-data

# install k3s and start
# - force use of docker for container runtime (the default is containerd)
curl -sfL https://get.k3s.io | sh -s - --docker
sudo systemctl enable k3s

# Setup kube config
mkdir -p $HOME/.kube
sudo k3s kubectl config view --raw > $HOME/.kube/config
