#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

ACTION=$1
if [ -z "$ACTION" ]; then ACTION="apply"; fi

# argo
# argo_version="v2.8.1"
# kubectl create namespace argo
# kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/${argo_version}/manifests/install.yaml
# kubectl create rolebinding default-admin --clusterrole=admin --serviceaccount=default:default
kubectl $ACTION -f k8s/argo-namespace.yml
kubectl $ACTION -n argo -f k8s/argo.yml
kubectl $ACTION -f k8s/default-admin-role.yml

# ADES
kubectl $ACTION -f k8s/ades.yml
