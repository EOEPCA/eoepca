#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"
cd "${ORIG_DIR}"

trap "cd '${ORIG_DIR}'" EXIT

function main() {
  public_ip=$(terraform output -state=../../creodias/terraform.tfstate -json | jq -r '.loadbalancer_fips.value[]')
  public_hostname="${public_ip}.nip.io"
  echo "Using PUBLIC HOSTNAME: ${public_hostname}"

  source $HOME/.local/robot/bin/activate
  pip install -r ./requirements.txt

  robot --variable PUBLIC_HOSTNAME:${public_hostname} .

  deactivate
}

main
