#!/bin/bash
echo "##### Deploy sample EOEPCA system on cluster #####"
ansible-playbook --vault-password-file=.vault_pass -i inventory/cf2-kube/hosts eoepca.yml