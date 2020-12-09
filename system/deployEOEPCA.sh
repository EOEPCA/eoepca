#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

TMP_KUBECONFIG="$PWD/kubeconfig.eoepca"

function onExit() {
  if test -f "$TMP_KUBECONFIG"; then rm "$TMP_KUBECONFIG"; fi
  cd "${ORIG_DIR}"
}

trap "onExit" EXIT

# Default to current branch
CURRENT_BRANCH="$(git branch --show-current)"
BRANCH="${BRANCH:-${CURRENT_BRANCH}}"

# Default to target 'minikube'
TARGET="${TARGET:-minikube}"

# Consolidate to a local kubeconfig - avoids problem of flux not handling paths in KUBECONFIG
kubectl config view --minify --flatten > "$TMP_KUBECONFIG"
export KUBECONFIG="$TMP_KUBECONFIG"

# Initialise flux in the cluster
flux bootstrap github \
  --owner=EOEPCA \
  --repository=eoepca \
  --branch="${BRANCH}" \
  --team=Developers \
  --path="system/${TARGET}"
