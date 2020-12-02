#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# Ref. https://helm.sh/docs/intro/install/
curl -sfL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash -s -

# Add helm repo for official Helm stable charts
helm repo add stable https://charts.helm.sh/stable
