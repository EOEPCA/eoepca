#!/bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo "##### Install Ansible #####"
sudo -H pip3 install setuptools
sudo -H pip3 install netaddr
sudo -H pip3 install ansible

echo "##### Install Swift client ####"
sudo apt install -y python3-swiftclient

echo "##### Install Kubernetes cluster through Bastion node #####"

echo "##### Configure access to network #####"
cd inventory/cf2-kube
SUBNET_ID=`terraform output -json | jq ".private_subnet_id.value"`
BASTION_IP=`terraform output -json | jq ".bastion_fips.value | .[]"`
echo "Network ID is ${SUBNET_ID}"
echo "Bastion IP is ${BASTION_IP}"
sed -i 's/\openstack_lbaas_subnet_id: .*/openstack_lbaas_subnet_id: '${SUBNET_ID}'/g' group_vars/all/openstack.yml
sed -i 's/\# openstack_lbaas_subnet_id/openstack_lbaas_subnet_id/g' group_vars/all/openstack.yml

if [ -z  "$VAULT_PASSWORD" ]; then
  echo "Please enter your Ansible Vault Password : "
  read -sr PASSWORD
  export VAULT_PASSWORD=${PASSWORD}
fi

rm -f creodias.tfstate 

swift auth
swift download -o creodias.tfstate eoepca-staging-terraform-state tfstate.tf

echo "##### Deploy Kubernetes cluster #####"
cd ../..
rm -f ssh-bastion.conf
ansible-playbook --flush-cache  --become -i inventory/cf2-kube/hosts cluster.yml

echo "##### Configure access to Kubernetes cluster through Bastion #####"
ansible-playbook --flush-cache  --vault-password-file=.vault_pass --become -i inventory/cf2-kube/hosts bastion.yml
