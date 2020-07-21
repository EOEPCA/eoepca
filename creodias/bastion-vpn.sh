#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

function main() {
  if hash sshuttle 2>/dev/null
  then
    bastion=$(terraform output -json | jq -r '.bastion_fips.value[]')
    subnet=$(terraform output -json | jq -r '.subnet_cidr.value')
    echo "Connecting to network ${subnet} via jump host ${bastion}"
    sshuttle -r "eouser@${bastion}" "${subnet}"
  else
    echo 1>&2 "ERROR: sshuttle not found. Aborting..."
    return 1
  fi
}

main
