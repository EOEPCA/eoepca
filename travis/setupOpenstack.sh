#!/bin/bash
# Install minikube and kubectl
TF_VER=0.12.24

echo "##### Update apt-get and install Python3 #####"
sudo apt-get update
sudo sh -c 'DEBIAN_FRONTEND=noninteractive && apt-get install python3 python3-pip' 

echo "##### Install python requirement #####"
sudo pip3 install -r terraform/NoR/requirements.txt

echo "##### Set CreoDIAS credentials #####"
/bin/bash ./terraform/NoR/openrc.sh
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""

echo "##### Installing Terraform version $TF_VER"
sudo apt-get install unzip
curl -sLo /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip
unzip -o /tmp/terraform.zip -d /tmp
chmod +x /tmp/terraform
sudo mv /tmp/terraform /usr/local/bin/

echo "##### Deploying Openstack environment"
cd terraform/NoR
terraform init -input=false openstack/
