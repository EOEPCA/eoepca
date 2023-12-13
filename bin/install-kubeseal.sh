#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

mkdir -p $HOME/.local/bin

VERSION="0.18.5"
DOWNLOAD="kubeseal-${VERSION}-linux-amd64.tar.gz"

# kubeseal
curl -sLO https://github.com/bitnami-labs/sealed-secrets/releases/download/v${VERSION}/${DOWNLOAD}
tar -C $HOME/.local/bin -xf ${DOWNLOAD} kubeseal
rm ${DOWNLOAD}

# summary
which kubeseal
kubeseal --version
