#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

echo "uninstall fleet components..."
helm -n fleet-system uninstall fleet
helm -n fleet-system uninstall fleet-crd
