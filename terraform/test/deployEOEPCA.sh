#!/bin/bash

# fail fast settings from https://dougrichardson.org/2018/08/03/fail-fast-bash-scripting.html
# set -euov pipefail
# Not supported in travis (xenial)
# shopt -s inherit_errexit

# Check presence of environment variables
TRAVIS_BUILD_DIR="${TRAVIS_BUILD_DIR:-.}"
DOCKER_EMAIL="${DOCKER_EMAIL:-none@none.com}"
DOCKER_USERNAME="${DOCKER_USERNAME:-none}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-none}"

# Create the K8S environment
cd ${TRAVIS_BUILD_DIR}/terraform/test 
terraform apply --auto-approve  --var="dh_user_email=${DOCKER_EMAIL}" \
                                --var="dh_user_name=${DOCKER_USERNAME}" \
                                --var="dh_user_password=${DOCKER_PASSWORD}"
