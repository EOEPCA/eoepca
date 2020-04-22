#!/bin/bash
echo "##### Obtaining list of hosts from remote state storage #####"
if [ -z "$REMOTE_STATE_FILE" ]; then
    echo "Please input the remote state file location:  "
    read -r REMOTE_FILE
    export REMOTE_STATE_FILE=${REMOTE_FILE} 
fi

curl $REMOTE_STATE_FILE -o creodias.tfstate

echo "##### Deploy sample EOEPCA system on cluster #####"
ansible-playbook --vault-password-file=.vault_pass -i inventory/cf2-kube/hosts eoepca.yml