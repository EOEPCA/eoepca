#!/bin/bash

# fail fast settings from https://dougrichardson.org/2018/08/03/fail-fast-bash-scripting.html
set -euov pipefail
# Not supported in travis (xenial)
# shopt -s inherit_errexit

# local host machine's minikube VM IP
minikubeIP=$(kubectl cluster-info | sed 's/\r$//' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\:[0-9]{1,4}')

# Create the K8S environment
terraform apply -input=false -auto-approve -var='db_username=$DB_USER' -var='db_password=$DB_PASSWORD' ./test

# wait for k8S and pods to start-up
sleep 60

# Various debug statements
debug=true
if ($debug == "true"); then

    # View cluster (kubectl) config in ~/.kube/config
    kubectl config view
    kubectl get nodes
    kubectl get secret db-user-pass -o yaml --namespace=eo-services
    kubectl get namespaces
    kubectl get pods --all-namespaces
    kubectl get deployments --namespace=eo-services template-service-deployment
    #- kubectl logs -lapp=catalogue-service --all-containers=true
    kubectl logs --namespace=eo-services deployment/template-service-deployment --all-containers=true
    kubectl logs --namespace=eo-services deployment/frontend --all-containers=true
    kubectl get service --namespace=eo-services template-svce -o json
    kubectl describe deployment --namespace=eo-services template-service-deployment
    kubectl describe service --namespace=eo-services template-svce
    kubectl describe service --namespace=eo-services frontend
    clusterIP=$(kubectl get svc --namespace=eo-services template-svce -o json | jq -r '.spec.clusterIP')
    echo Cluster IP of template-svce is $clusterIP

fi

echo Testing connectivity with the services
templateSvcNodePort=$(kubectl get service --namespace=eo-services template-svce --output=jsonpath='{.spec.ports[0].nodePort}')
revProxyNodePort=$(kubectl get svc --namespace=eo-services frontend --output=jsonpath='{.spec.ports[0].nodePort}')

if ($debug == "true"); then
    # Both the micro-service and reverse proxy are exposed as node ports for testing purposes
    # curl echoes both ports to check connectivity.  The second set echoes the server headers should report nginx and javalin
    curl http://${minikubeIP}:${revProxyNodePort}/search | jq '.'
    curl http://${minikubeIP}:${templateSvcNodePort}/search | jq '.'
    curl -si http://${minikubeIP}:${revProxyNodePort}/search
    curl -si http://${minikubeIP}:${templateSvcNodePort}/search
fi

kubectl logs --namespace=eo-services deployment/frontend --all-containers=true
kubectl logs --namespace=eo-services deployment/template-service-deployment --all-containers=true

if ($debug == "true"); then
    # Namespace: eo-services
    kubectl describe deployments --namespace=eo-services
    kubectl describe services    --namespace=eo-services
    kubectl describe jobs        --namespace=eo-services

    # Namespace: eo-user-compute
    kubectl describe deployments --namespace=eo-user-compute
    kubectl describe services    --namespace=eo-user-compute
    kubectl describe jobs        --namespace=eo-user-compute
    kubectl describe quota --namespace=eo-user-compute
fi

kubectl describe job pi   --namespace=eo-user-compute

# Debug Persistent Volumes, PV Claims and Storage Classes
kubectl describe pv
kubectl describe pvc --namespace=eo-user-compute
kubectl get storageclass

kubectl logs --namespace=eo-user-compute job/pi --all-containers=true
