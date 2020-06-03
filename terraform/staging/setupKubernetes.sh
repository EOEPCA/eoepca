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
sed -i 's/\openstack_lbaas_subnet_id: .*/openstack_lbaas_subnet_id: '${SUBNET_ID}'/g' group_vars/all/openstack.yml
sed -i 's/\# openstack_lbaas_subnet_id/openstack_lbaas_subnet_id/g' group_vars/all/openstack.yml

if [ -z  "$VAULT_PASSWORD" ]; then
  echo "Please enter your Ansible Vault Password : "
  read -sr PASSWORD
  export VAULT_PASSWORD=${PASSWORD}
fi

export OP_TOKEN=$(curl -s -i \
-H "Content-Type: application/json" \
-d "
{ \"auth\": {
\"identity\": {
\"methods\": [\"password\"],
\"password\": {
\"user\": {
\"name\": \"$OS_USERNAME\",
\"domain\": { \"name\": \"$OS_USER_DOMAIN_NAME\" },
\"password\": \"$OS_PASSWORD\"
    }
   }
  },
\"scope\": { \"project\": {
\"name\": \"eoepca\",
\"domain\": { \"id\": \"$OS_PROJECT_DOMAIN_ID\"
     }
    }
   }
  }
}" \
https://cf2.cloudferro.com:5000/v3/auth/tokens | grep Subject-Token |  awk '{printf $2}' | sed -e 's/[\r\n]//g') 

curl -s -o creodias.tfstate -H "X-Auth-Token: $OP_TOKEN" https://cf2.cloudferro.com:8080/swift/v1/AUTH_${OS_PROJECT_ID}/eoepca-staging-terraform-state/tfstate.tf


echo "##### Deploy Kubernetes cluster #####"
cd ../..
ansible-playbook --become -i inventory/cf2-kube/hosts cluster.yml

echo "##### Configure access to Kubernetes cluster through Bastion #####"
ansible-playbook --vault-password-file=.vault_pass --become -i inventory/cf2-kube/hosts bastion.yml
