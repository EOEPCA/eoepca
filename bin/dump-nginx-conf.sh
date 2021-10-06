#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

# nginx.conf
echo -n "Dumping nginx.conf for ingress controller..."
kubectl -n ingress-nginx exec -it svc/ingress-nginx-controller -- cat /etc/nginx/nginx.conf
echo " done"
