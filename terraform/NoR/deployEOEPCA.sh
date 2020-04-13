#!/bin/bash
echo "##### Configure access to network #####"
cd inventory/cf2-kube
BASTION_IP=`terraform output -json | jq ".bastion_fips.value | .[]"`

cd ../..
rm kubernetes_hosts
touch kubernetes_hosts
echo "[bastion]" >> kubernetes_hosts
echo "${BASTION_IP}" >> kubernetes_hosts
echo "Bastion IP is ${BASTION_IP}"

echo "##### Deploy sample EOEPCA system on cluster #####"
ansible-playbook --private-key ~/.ssh/id_rsa -u eouser -i kubernetes_hosts eoepca.yml