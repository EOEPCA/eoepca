#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# Deduce the public IP-address of our k8s cluster, on the assumption that we
# have a 'local kube' deployment (e.g. minikube/k3s/microk8s, etc.).
# Deduced as the IP address of the k8s node (assumed single node).
function main() {
  LOCALKUBE_IP="$(kubectl get nodes -o json | jq -r '.items[0].status.addresses[] | select(.type == "InternalIP") | .address' 2>/dev/null)" || unset LOCALKUBE_IP
  if [ -n "${LOCALKUBE_IP}" -a "${LOCALKUBE_IP}" != "null" ]
  then
    echo "$LOCALKUBE_IP"
    return 0
  else
    return 1
  fi
}

main "$@"
