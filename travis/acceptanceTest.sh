#!/bin/bash

# Various debug statements
debug=false

if ($debug == "true"); then

    # View cluster (kubectl) config in ~/.kube/config
    kubectl config view
    kubectl get nodes
    kubectl get namespaces
    kubectl get pods --all-namespaces
    kubectl get deployments --all
    kubectl get services --all
    kubectl describe deployments --all
    kubectl describe services --all

fi

echo Testing connectivity with the infrastructure
# local host machine's minikube VM IP
kubeIP=$(kubectl cluster-info | sed 's/\r$//' | grep 'master' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

echo "Minikube or Kubernetes master IP is ${kubeIP}"

echo Acceptance testing
# echo \#1 proc-ades
# ADES_PORT=$(kubectl get services/eoepca-ades-core -o go-template='{{(index .spec.ports 0).nodePort}}')
# echo "eoepca-ades-core service is acccessible on ${kubeIP}:${ADES_PORT}"
# curl -s -L $kubeIP:$ADES_PORT/wps3/processes/argo -H "accept: application/json"
~/.local/bin/robot test/acceptance

# echo \#2 um-login
# curl -XGET https://${kubeIP}/.well-known/openid-configuration -k
# curl -XGET https://${kubeIP}/.well-known/scim-configuration -k

