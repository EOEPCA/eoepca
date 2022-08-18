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

DOMAIN="${1:-set-domain-here}"
USER="${2:-set-user-here}"
PASS="${3:-set-pass-here}"

secretYaml() {
  kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
    --from-literal="OS_DOMAINNAME=${DOMAIN}" \
    --from-literal="OS_PASSWORD=${PASS}" \
    --from-literal="OS_USERNAME=${USER}" \
    --dry-run=client -o yaml
}

# Create Secret and then pipe to kubeseal to create the SealedSecret
secretYaml | kubeseal -o yaml --controller-name eoepca-sealed-secrets --controller-namespace infra > ${SECRET_NAME}-access.yaml
