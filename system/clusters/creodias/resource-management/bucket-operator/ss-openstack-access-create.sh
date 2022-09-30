#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

onExit() {
  cd "${ORIG_DIR}"
}

trap onExit EXIT

SECRET_NAME="openstack"
NAMESPACE="rm"

OS_USERNAME="${1:-set-username-here}"
OS_PASSWORD="${1:-set-password-here}"
OS_DOMAINNAME="${3:-set-domain-name-here}"

secretYaml() {
  kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
    --from-literal=username="${OS_USERNAME}" \
    --from-literal=password="${OS_PASSWORD}" \
    --from-literal=domainname="${OS_DOMAINNAME}" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > ss-${SECRET_NAME}.yaml
