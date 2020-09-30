#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

ACTION="apply"
if test "$1" = "delete" -o "$1" = "destroy"; then ACTION="delete"; fi

if test "$ACTION" = "apply"
then
    ./embed-kubeconfig.sh
    ./create-ades-kube-configmap-yaml.sh
fi

if test ! -f ades-kube-configmap.yaml
then
    echo "ERROR: need to generate file ades-kube-configmap.yaml"
    exit 1
fi

kubectl "${ACTION}" -f ades-kube-configmap.yaml
kubectl "${ACTION}" -f ades.yaml
