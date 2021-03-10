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

# Consolidate to a local kubeconfig - avoids problem of flux not handling paths in KUBECONFIG
kubectl config view --minify --flatten > "$TMP_KUBECONFIG"
export KUBECONFIG="$TMP_KUBECONFIG"

# Uninstall flux
flux uninstall --silent
