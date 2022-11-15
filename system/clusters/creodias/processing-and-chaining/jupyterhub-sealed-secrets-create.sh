#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

SECRET_NAME="jupyterhub-secrets"
NAMESPACE="pde-hub"

OAUTH_CLIENT_ID="${1:-set-client-id-here}"
OAUTH_CLIENT_SECRET="${2:-set-client-secret-here}"

clientConfigFile() {
  cat - <<EOF
hub:
  config:
    GenericOAuthenticator:
      client_id: ${OAUTH_CLIENT_ID}
      client_secret: ${OAUTH_CLIENT_SECRET}
    JupyterHub:
      authenticator_class: generic-oauth  
EOF
}

secretYaml() {
  kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
    --from-literal="values.yaml=$(clientConfigFile)" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > jupyterhub-sealed-secrets.yaml
