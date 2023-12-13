#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

# flux
curl -s https://fluxcd.io/install.sh | sudo bash

# flux ctl
curl -sLo $HOME/.local/bin/fluxctl https://github.com/fluxcd/flux/releases/download/1.22.2/fluxctl_linux_amd64
chmod +x $HOME/.local/bin/fluxctl
