#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

7z a -p cluster.7z cluster.yml cluster.rkestate kube_config_cluster.yml
