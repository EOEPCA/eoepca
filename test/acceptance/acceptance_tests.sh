#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

function setup_venv() {
  if [ ! -d venv ]
  then
    if python3 -m venv --help >/dev/null 2>&1
    then
      echo "INFO: creating venv..."
      python3 -m venv venv
    else
      echo "ERROR: python virtualenv package is required. Please install (e.g. apt install python3-venv)"
      return 1
    fi
  else
    echo "INFO: updating existing venv..."
  fi
  echo "INFO: activate venv and update..."
  source venv/bin/activate
  python -m pip install -U pip
}

function install_robot_framework() {
  echo "INFO: Installing/updating Robot Framework and dependencies..."
  pip install -U robotframework \
  && pip install -U docutils \
  && pip install -U robotframework-requests \
  && pip install -U robotframework-seleniumlibrary \
  && pip install -U robotframework-sshlibrary \
  && pip install -U webdrivermanager
}

function install_test_requirements() {
  pip install -r ./requirements.txt
}

function run_acceptance_tests() {
  public_ip=$(terraform output -state=../../creodias/terraform.tfstate -json | jq -r '.loadbalancer_fips.value[]' 2>/dev/null) || unset public_ip
  public_hostname="${public_ip}.nip.io"
  echo "INFO: Using PUBLIC HOSTNAME: ${public_hostname}"

  echo "INFO: Invoking acceptance tests..."
  robot --variable PUBLIC_HOSTNAME:${public_hostname} .
}

function main() {
  setup_venv \
  && install_robot_framework \
  && install_test_requirements \
  && run_acceptance_tests

  hash deactivate 2>/dev/null && deactivate
}

main "$@"
