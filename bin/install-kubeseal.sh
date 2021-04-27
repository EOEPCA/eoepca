#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

# kubeseal
curl -sLo $HOME/.local/bin/kubeseal https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.15.0/kubeseal-linux-amd64
chmod +x $HOME/.local/bin/kubeseal
