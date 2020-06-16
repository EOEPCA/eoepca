#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

ACTION=$1
if [ -z "$ACTION" ]; then ACTION="apply"; fi

kubectl delete -f k8s/workspace.yml
kubectl delete -f k8s/storage.yml

if [ "$ACTION" = "apply" ]
then
  kubectl apply -f k8s/workspace.yml
  kubectl apply -f k8s/storage-workspace.yml
fi
