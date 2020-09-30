#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

./embed-kubeconfig.sh

kubectl create configmap ades-kubeconfig --from-file=$HOME/.kube/config --dry-run=client -o yaml >ades-kube-configmap.yaml
