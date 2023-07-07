#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

SECRET_NAME="rm-minio-root-credentials"
NAMESPACE="rm"

ROOT_USER="${1:-set-root-user-here}"
ROOT_PASSWORD="${2:-set-root-password-here}"

secretYaml() {
  kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
    --from-literal="rootUser=${ROOT_USER}" \
    --from-literal="rootPassword=${ROOT_PASSWORD}" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > ss-${SECRET_NAME}.yaml
