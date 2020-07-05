#!/usr/bin/env bash
# Install minikube and kubectl

echo "##### Update apt-get and install Python3 #####"
sudo apt-get update
sudo sh -c 'DEBIAN_FRONTEND=noninteractive && apt-get install python3 python3-pip'


echo "##### Install python requirement #####"
sudo -H pip3 install -r requirements.txt
sudo -H pip3 install python-openstackclient

echo "##### Set CreoDIAS credentials #####"
./openrc.sh

echo "##### Generate keys for project #####"
KEY=`grep "public_key_path" ./inventory/cf2-kube/cluster.tfvars | awk -F'"' '{print $2}'`
KEY=${KEY%".pub"}
KEY="${KEY/#\~/$HOME}"
echo -e 'y\n' | ssh-keygen -b 2048 -t rsa -f $KEY -N "" 

echo "##### Deploying Openstack environment"
cd inventory/cf2-kube
terraform init -input=false contrib/terraform/openstack

while [ "$1" != "" ]; do
    case $1 in
        -a | --apply )          terraform apply -auto-approve -var-file=cluster.tfvars contrib/terraform/openstack
                                ;;
        -d | --destroy )        terraform destroy -auto-approve -var-file=cluster.tfvars contrib/terraform/openstack
                                ;;
        -h | --help )           #usage
                                exit
                                ;;
        * )                     #usage
                                exit 1
    esac
    shift
done

