#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

function main() {
  cat $HOME/.ssh/id_rsa.pub >>$HOME/.ssh/authorized_keys
}

main "$@"
