#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

echo "install the Fleet CustomResourcesDefintions..."
helm -n fleet-system upgrade -i --create-namespace --wait \
    fleet-crd https://github.com/rancher/fleet/releases/download/v0.3.1/fleet-crd-0.3.1.tgz

echo "install the Fleet controllers..."
helm -n fleet-system upgrade -i --create-namespace --wait \
    fleet https://github.com/rancher/fleet/releases/download/v0.3.1/fleet-0.3.1.tgz
