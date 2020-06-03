#!/bin/bash
if [ -z  "$VAULT_PASSWORD" ]; then
  echo "Please enter your Ansible Vault Password : "
  read -sr PASSWORD
  export VAULT_PASSWORD=${PASSWORD}
fi

echo "##### Deploy sample EOEPCA system on cluster #####"
ansible-playbook --vault-password-file=.vault_pass -i inventory/cf2-kube/hosts eoepca.yml