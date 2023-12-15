#!/usr/bin/env bash

JUPYTERHUB_CRYPT_KEY="e002661916e648572fccc6bea7348a26bc108d731240ce4915e6efcb43f17832"
OAUTH_CLIENT_ID="4466dc5e-d7ac-41b6-b645-ca13b31ae6be"
OAUTH_CLIENT_SECRET="6b118fb2-e600-4c43-821d-362229d4c6f1"

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
