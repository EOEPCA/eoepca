#!/bin/bash

# fail fast settings from https://dougrichardson.org/2018/08/03/fail-fast-bash-scripting.html
set -euov pipefail
# Not supported in travis (xenial)
# shopt -s inherit_errexit

# Create the K8S environment
terraform apply -input=false -auto-approve -var='db_username=$DB_USER' -var='db_password=$DB_PASSWORD' ./test

# Various debug statements
debug=false
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
    kubectl get service --namespace=eo-services template-service -o json
    kubectl describe deployment --namespace=eo-services template-service-deployment
    kubectl describe service --namespace=eo-services template-service
    kubectl describe service --namespace=eo-services frontend

fi

echo Testing connectivity with the services
clusterIP=$(kubectl get svc --namespace=eo-services template-service -o json | jq -r '.spec.clusterIP')
templateSvcNodePort=$(kubectl get service --namespace=eo-services template-service --output=jsonpath='{.spec.ports[0].port}')

echo Cluster IP of template-service is ${clusterIP}:${templateSvcNodePort}
revProxyIP=$(kubectl get svc --namespace=eo-services frontend -o json | jq -r '.spec.clusterIP')
revProxyNodePort=$(kubectl get svc --namespace=eo-services frontend --output=jsonpath='{.spec.ports[0].port}')

echo Cluster IP of frontend is ${revProxyIP}:${revProxyNodePort}

if ($debug == "true"); then
    # local host machine's minikube VM IP
    minikubeIP=$(kubectl cluster-info | sed 's/\r$//' | grep 'master' | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\:[0-9]{1,4}')
    echo "MiniKupe Master IP is ${minikubeIP}"
    # Both the micro-service and reverse proxy are exposed as node ports for testing purposes
    # curl echoes both ports to check connectivity.  The second set echoes the server headers should report nginx and javalin
    curl http://${revProxyIP}:${revProxyNodePort}/search | jq '.'
    curl http://${clusterIP}:${templateSvcNodePort}/search | jq '.'
    curl -si http://${revProxyIP}:${revProxyNodePort}/search
    curl -si http://${clusterIP}:${templateSvcNodePort}/search
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

# Debug Persistent Volumes, PV Claims and Storage Classes
kubectl describe pv
kubectl describe pvc --namespace=eo-user-compute
kubectl get storageclass
