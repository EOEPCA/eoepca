#!/bin/bash

echo "##### Install Ansible #####"
sudo -H pip3 install setuptools
sudo -H pip3 install netaddr
sudo -H pip3 install ansible

echo "##### Install Kubernetes cluster through Bastion node #####"

echo "##### Configure access to network #####"
cd inventory/cf2-kube
SUBNET_ID=`terraform output -json | jq ".private_subnet_id.value"`
BASTION_IP=`terraform output -json | jq ".bastion_fips.value | .[]"`
echo "Network ID is ${SUBNET_ID}"
echo "Bastion IP is ${BASTION_IP}"
sed -i 's/\openstack_lbaas_subnet_id: \".*\"/openstack_lbaas_subnet_id: '${SUBNET_ID}'/g' group_vars/all/openstack.yml
sed -i 's/\# openstack_lbaas_subnet_id/openstack_lbaas_subnet_id/g' group_vars/all/openstack.yml

echo "##### Obtaining list of hosts from remote state storage #####"
if [ -z "$REMOTE_STATE_FILE" ]; then
    echo "Please input the remote state file location:  "
    read -r REMOTE_FILE
    export REMOTE_STATE_FILE=${REMOTE_FILE} 
fi

curl $REMOTE_STATE_FILE -o creodias.tfstate

echo "##### Deploy Kubernetes cluster #####"
cd ../..
ansible-playbook --become -i inventory/cf2-kube/hosts cluster.yml

echo "##### Configure access to Kubernetes cluster through Bastion #####"
ansible-playbook --vault-password-file=.vault_pass --become -i inventory/cf2-kube/hosts bastion.yml