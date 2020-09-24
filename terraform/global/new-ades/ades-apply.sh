#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

if test ! -f ades-kube-configmap.yaml
then
    echo "ERROR: need to generate file ades-kube-configmap.yaml"
    exit 1
fi

ACTION="apply"
if "$1" = "delete" -o "$1" = "destroy"; then ACTION="delete"; fi

kubectl "${ACTION}" -f ades-kube-configmap.yaml
kubectl "${ACTION}" -f ades.yaml
