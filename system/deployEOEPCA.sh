#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

CURRENT_BRANCH="$(git branch --show-current)"
BRANCH="${BRANCH:-${CURRENT_BRANCH}}"

echo "Register EOEPCA GitRepo..."
helm upgrade -i --set branch="${BRANCH}" eoepca ./eoepca-repos
