#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# Sealed Secrets
if test -f "sealed-secrets-master.key"; then kubectl apply -f "sealed-secrets-master.key"; fi
helm repo add bitnami-sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm upgrade -i --version 1.13.2 --create-namespace --namespace flux-system eoepca-sealed-secrets bitnami-sealed-secrets/sealed-secrets

# Cert Manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm upgrade -i --version v1.2.0 --create-namespace --namespace common eoepca-cert-manager jetstack/cert-manager
