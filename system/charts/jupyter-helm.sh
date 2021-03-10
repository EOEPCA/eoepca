#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

# helm upgrade -i -f storage-values.yaml rac-storage storage
helm template -f jupyter-values.yaml rac-jupyter jupyter
