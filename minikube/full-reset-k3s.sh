#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

k3s-uninstall.sh
rm -rf terraform.tfstate*
sudo rm -rf /kubedata
if [ "$1" != "destroy" ]; then ./setup-k3s.sh; fi
