#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

echo "Register EOEPCA GitRepo..."
helm install --set branch=`git branch --show-current` eoepca ./eoepca-repos

echo "Check EOEPCA GitRepo status..."
helm status eoepca

