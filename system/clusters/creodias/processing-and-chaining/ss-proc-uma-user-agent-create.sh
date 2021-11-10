#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

SECRET_NAME="proc-uma-user-agent"
NAMESPACE="proc"

CLIENT_ID="${1:-set-client-id-here}"
CLIENT_SECRET="${2:-set-client-secret-here}"

clientConfigFile() {
  cat - <<EOF
client-id: ${CLIENT_ID}
client-secret: ${CLIENT_SECRET}
EOF
}

secretYaml() {
  kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
    --from-literal="client.yaml=$(clientConfigFile)" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > ss-${SECRET_NAME}.yaml
