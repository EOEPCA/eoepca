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
    echo "INFO: activate venv and update..."
    source venv/bin/activate
    python -m pip install -U pip
    pip install -U wheel
  else
    echo "INFO: activate venv..."
    source venv/bin/activate
  fi
}

function install_robot_framework() {
  if ! hash robot 2>/dev/null
  then
    echo "INFO: Installing Robot Framework and dependencies..."
    pip install -U robotframework \
    && pip install -U docutils \
    && pip install -U robotframework-requests \
    && pip install -U robotframework-seleniumlibrary \
    && pip install -U robotframework-sshlibrary
  else
    echo "INFO: Using existing Robot Framework installation"
  fi
}

function install_test_requirements() {
  pip install -r ./requirements.txt
}

function install_chromedriver() {
  if ! hash chromedriver 2>/dev/null
  then
    ../bin/install-chromedriver.sh
  else
    echo "INFO: Using existing chromedriver installation"
  fi
}

function deduce_public_ip() {
  # Scrape VM infrastructure topology from terraform outputs
  DEPLOYMENT_PUBLIC_IP=$(${BIN_DIR}/../../bin/get-public-ip.sh) || unset DEPLOYMENT_PUBLIC_IP
  PUBLIC_IP="${PUBLIC_IP:-${DEPLOYMENT_PUBLIC_IP:-none}}"
  if [ "${PUBLIC_IP}" = "none" ]; then echo "ERROR: invalid Public IP (${PUBLIC_IP}). Aborting..."; exit 1; fi
}

function run_acceptance_tests() {
  public_hostname="${PUBLIC_IP}.nip.io"
  echo "INFO: Using PUBLIC HOSTNAME: ${public_hostname}"

  echo "INFO: Invoking acceptance tests..."
  robot --variable PUBLIC_HOSTNAME:${public_hostname} .
  # robot --variable PUBLIC_HOSTNAME:${public_hostname} --suite Acceptance.UserManagement.UserProfile .
  # robot --variable PUBLIC_HOSTNAME:${public_hostname} --suite Acceptance.Processing.ADES .
  # robot --variable PUBLIC_HOSTNAME:${public_hostname} --suite Acceptance.Processing.ADES.WPS .

}

function main() {
  setup_venv \
  && install_robot_framework \
  && install_chromedriver \
  && install_test_requirements \
  && deduce_public_ip \
  && run_acceptance_tests
  STATUS=$?
  hash deactivate 2>/dev/null && deactivate
  return $STATUS
}

main "$@"
