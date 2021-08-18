#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

CLIENT_ID="${1:-dummy-value-id}"
CLIENT_SECRET="${2:-dummy-value-secret}"

secretYaml() {
  kubectl -n test create secret generic dummy-service-agent \
    --from-literal="client-id=${CLIENT_ID}" \
    --from-literal="client-secret=${CLIENT_SECRET}" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > ss-dummy-service-agent.yaml
