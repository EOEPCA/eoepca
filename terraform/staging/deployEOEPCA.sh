#!/bin/bash
# Check presence of environment variables
TRAVIS_BUILD_DIR="${TRAVIS_BUILD_DIR:-.}"
DOCKER_EMAIL="${DOCKER_EMAIL:-none@none@none.com}"
DOCKER_USERNAME="${DOCKER_USERNAME:-none}"
DOCKER_PASSWORD="${DOCKER_PASSWORD:-none}"
WSPACE_USERNAME="${WSPACE_USERNAME:-none}"
WSPACE_PASSWORD="${WSPACE_PASSWORD:-none}"

if [ -z  "$VAULT_PASSWORD" ]; then
  echo "Please enter your Ansible Vault Password : "
  read -sr PASSWORD
  export VAULT_PASSWORD=${PASSWORD}
fi

echo "##### Deploy sample EOEPCA system on cluster #####"
ansible-playbook --vault-password-file=.vault_pass \
                  --extra-vars "DOCKER_EMAIL=$DOCKER_EMAIL DOCKER_USERNAME=$DOCKER_USERNAME DOCKER_PASSWORD=$DOCKER_PASSWORD WSPACE_USERNAME=$WSPACE_USERNAME WSPACE_PASSWORD=$WSPACE_PASSWORD" \
                  -i inventory/cf2-kube/hosts eoepca.yml
