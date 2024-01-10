#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

PROXY_CLIENT_SECRET="${1:-tbd}"
PROXY_ENCRYPTION_KEY="${2:-tbd}"

secretYaml() {
  kubectl -n um create secret generic um-identity-service-identity-api-protection \
    --from-literal="PROXY_CLIENT_SECRET=${PROXY_CLIENT_SECRET}" \
    --from-literal="PROXY_ENCRYPTION_KEY=${PROXY_ENCRYPTION_KEY}" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > ss-identity-api-protection.yaml
