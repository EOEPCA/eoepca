#!/bin/bash
echo "##### Obtaining list of hosts from remote state storage #####"
if [ -z "$REMOTE_STATE_FILE" ]; then
    echo "Please input the remote state file location:  "
    read -r REMOTE_FILE
    export REMOTE_STATE_FILE=${REMOTE_FILE} 
fi

curl $REMOTE_STATE_FILE -o creodias.tfstate

echo "##### Configure access to network #####"
if [ ! -z "$PRIVATE_KEY_DATA" ]; then
  rm ~/.ssh/id_rsa
  touch ~/.ssh/id_rsa
  echo $PRIVATE_KEY_DATA >> ~/.ssh/id_rsa
fi

echo "##### Deploy sample EOEPCA system on cluster #####"
ansible-playbook --private-key ~/.ssh/id_rsa -u eouser -i inventory/cf2-kube/hosts eoepca.yml