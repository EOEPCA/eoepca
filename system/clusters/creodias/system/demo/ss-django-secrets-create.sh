#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

SECRET_NAME="django-secrets"
NAMESPACE="demo"

client_id="${1:-set-client-id-here}"
client_secret="${2:-set-client-secret-here}"
django_secret="${3:-set-django-secret-here}"
keycloak_client_id="${4:-set-keycloak-client-id-here}"
keycloak_client_secret="${5:-set-keycloak-client-secret-here}"

secretYaml() {
  kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
    --from-literal=OIDC_RP_CLIENT_ID="${client_id}" \
    --from-literal=OIDC_RP_CLIENT_SECRET="${client_secret}" \
    --from-literal=DJANGO_SECRET="${django_secret}" \
    --from-literal=KEYCLOAK_OIDC_RP_CLIENT_ID="${keycloak_client_id}" \
    --from-literal=KEYCLOAK_OIDC_RP_CLIENT_SECRET="${keycloak_client_secret}" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > ss-${SECRET_NAME}.yaml