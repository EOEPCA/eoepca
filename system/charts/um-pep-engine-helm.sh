#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

helm upgrade -i -f um-pep-engine-values.yaml rac-um-pep-engine pep-engine
