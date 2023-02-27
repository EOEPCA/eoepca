#!/usr/bin/env bash

JUPYTERHUB_CRYPT_KEY="****"
OAUTH_CLIENT_ID="*****"
OAUTH_CLIENT_SECRET="*****"

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

SECRET_NAME="application-hub-secrets"
NAMESPACE="proc"

# JUPYTERHUB_CRYPT_KEY=$(openssl rand -hex 32)
# OAUTH_CLIENT_ID="${1:-set-client-id-here}"
# OAUTH_CLIENT_SECRET="${2:-set-client-secret-here}"



secretYaml() {
  kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
    --from-literal="JUPYTERHUB_CRYPT_KEY=${JUPYTERHUB_CRYPT_KEY}" \
    --from-literal="OAUTH_CLIENT_ID=${OAUTH_CLIENT_ID}" \
    --from-literal="OAUTH_CLIENT_SECRET=${OAUTH_CLIENT_SECRET}" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > application-hub-sealed-secrets.yaml
