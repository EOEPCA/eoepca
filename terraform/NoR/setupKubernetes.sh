#!/bin/bash

echo "##### Install Ansible #####"
sudo pip3 install --user ansible

echo "##### Install Kubernetes cluster through Bastion node #####"

echo "##### Configure access to network #####"
cd inventory/cf2-kube
SUBNET_ID=`terraform output -json | jq ".private_subnet_id.value"`
BASTION_IP=`terraform output -json | jq ".bastion_fips.value | .[]"`
echo "Network ID is ${SUBNET_ID}"
echo "Bastion IP is ${BASTION_IP}"
sed -i 's/\openstack_lbaas_subnet_id: \".*\"/openstack_lbaas_subnet_id: '${SUBNET_ID}'/g' group_vars/all/openstack.yml
sed -i 's/\# openstack_lbaas_subnet_id/openstack_lbaas_subnet_id/g' group_vars/all/openstack.yml

echo "##### Deploy Kubernetes cluster #####"
cd ../..
ansible-playbook --flush-cache --become -i inventory/cf2-kube/hosts cluster.yml

echo "##### Configure access to Kubernetes cluster through Bastion #####"
ansible-playbook --flush-cache --become -i inventory/cf2-kube/hosts bastion.yml