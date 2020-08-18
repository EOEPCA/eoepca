#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

function main() {
  gluster peer probe rke01
  gluster volume create volume1 replica 2 rke01:/gluster-storage rke02:/gluster-storage force
  gluster volume start volume1
  gluster volume status
}

main "$@"
