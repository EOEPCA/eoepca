#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

function main() {
  if hash sshuttle 2>/dev/null
  then
    bastion=$(terraform output -state=../creodias/terraform.tfstate -json | jq -r '.bastion_fips.value[]' 2>/dev/null) || unset bastion
    subnet=$(terraform output -state=../creodias/terraform.tfstate -json | jq -r '.subnet_cidr.value' 2>/dev/null) || unset subnet
    echo "Connecting to network ${subnet} via jump host ${bastion}"
    sshuttle "$@" -r "eouser@${bastion}" "${subnet}"
  else
    echo 1>&2 "ERROR: sshuttle not found. Aborting..."
    return 1
  fi
}

main "$@"
