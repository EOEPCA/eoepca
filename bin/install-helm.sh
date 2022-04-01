#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# For installation consisntecy
export HELM_INSTALL_DIR="$HOME/.local/bin"
# Ref. https://helm.sh/docs/intro/install/
curl -sfL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -s -

# Add helm repo for official Helm stable charts
helm repo add stable https://charts.helm.sh/stable
