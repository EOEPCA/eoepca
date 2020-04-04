#!/bin/bash
echo "##### Install Kubernetes cluster through Bastion node #####"

echo "##### Configure access to network #####"
cd inventory/cf2-kube
SUBNET_ID=`terraform output -json | jq ".private_subnet_id.value"`
echo "Network ID is ${SUBNET_ID}"
sed -i 's/\openstack_lbaas_subnet_id: \".*\"/openstack_lbaas_subnet_id: '${SUBNET_ID}'/g' group_vars/all/openstack.yml
sed -i 's/\# openstack_lbaas_subnet_id/openstack_lbaas_subnet_id/g' group_vars/all/openstack.yml

echo "##### Deploy Kubernetes cluster #####"
cd ../..
ansible-playbook -v --become -i inventory/cf2-kube/hosts cluster.yml
