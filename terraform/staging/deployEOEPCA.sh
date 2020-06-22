#!/bin/bash
if [ -z  "$VAULT_PASSWORD" ]; then
  echo "Please enter your Ansible Vault Password : "
  read -sr PASSWORD
  export VAULT_PASSWORD=${PASSWORD}
fi

echo "##### Deploy sample EOEPCA system on cluster #####"
ansible-playbook --vault-password-file=.vault_pass \
                  --extra-vars "DOCKER_EMAIL=$DOCKER_EMAIL DOCKER_USERNAME=$DOCKER_USERNAME DOCKER_PASSWORD=$DOCKER_PASSWORD" \
                  -i inventory/cf2-kube/hosts eoepca.yml
