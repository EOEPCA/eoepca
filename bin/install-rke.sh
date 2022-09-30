#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

# kubectl
curl -sLo $HOME/.local/bin/rke https://github.com/rancher/rke/releases/download/v1.3.13/rke_linux-amd64
chmod +x $HOME/.local/bin/rke
