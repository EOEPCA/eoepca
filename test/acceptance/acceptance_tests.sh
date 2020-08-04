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
  # python components
  echo "INFO: Installing/updating Robot Framework and dependencies..."
  pip install -U robotframework \
  && pip install -U docutils \
  && pip install -U robotframework-requests \
  && pip install -U robotframework-seleniumlibrary \
  && pip install -U robotframework-sshlibrary \
  && pip install -U webdrivermanager
  # Chrome driver
  echo "INFO: Installing chrome webdriver..."
  webdrivermanager chrome:83.0.4103.39
}

function install_test_requirements() {
  pip install -r ./requirements.txt
}

function deduce_public_ip() {
  # Scrape VM infrastructure topology from terraform outputs
  if hash terraform 2>/dev/null
  then
    DEPLOYMENT_PUBLIC_IP="$(terraform output -state=../../creodias/terraform.tfstate -json | jq -r '.loadbalancer_fips.value[]' 2>/dev/null)" || unset DEPLOYMENT_PUBLIC_IP
    if [ "${DEPLOYMENT_PUBLIC_IP}" = "null" ]; then unset DEPLOYMENT_PUBLIC_IP; fi
  fi
  if hash minikube 2>/dev/null; then MINIKUBE_IP=$(minikube ip 2>/dev/null) || unset MINIKUBE_IP; fi
  PUBLIC_IP="${PUBLIC_IP:-${DEPLOYMENT_PUBLIC_IP:-${MINIKUBE_IP:-none}}}"
  if [ "${PUBLIC_IP}" = "none" ]; then echo "ERROR: invalid Public IP (${PUBLIC_IP}). Aborting..."; exit 1; fi
}

function run_acceptance_tests() {
  public_hostname="${PUBLIC_IP}.nip.io"
  echo "INFO: Using PUBLIC HOSTNAME: ${public_hostname}"

  echo "INFO: Invoking acceptance tests..."
  robot --variable PUBLIC_HOSTNAME:${public_hostname} .
}

function main() {
  setup_venv \
  && install_robot_framework \
  && install_test_requirements \
  && deduce_public_ip \
  && run_acceptance_tests

  hash deactivate 2>/dev/null && deactivate
}

main "$@"
