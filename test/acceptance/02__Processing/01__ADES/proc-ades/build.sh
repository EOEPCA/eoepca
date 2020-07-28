#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

docker build -t eoepca/proc-ades:localkube .
docker push eoepca/proc-ades:localkube
