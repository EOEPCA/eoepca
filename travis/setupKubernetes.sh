#!/bin/bash
echo "##### Install Kubernetes cluster through Bastion node #####"

echo "##### Configure access to network #####"
cd terraform/NoR
SUBNET_ID=`terraform output -json | jq ".private_subnet_id.value"`
echo "Network ID is ${SUBNET_ID}"
sed -i 's/\# openstack_lbaas_subnet_id: \"Neutron subnet ID (not network ID) to create LBaaS VIP\"/openstack_lbaas_floating_network_id: \"'${SUBNET_ID}'\"/' inventory/cf2-kube/group_vars/all/openstack.yml

