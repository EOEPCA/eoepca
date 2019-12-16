#!/bin/bash

# fail fast settings from https://dougrichardson.org/2018/08/03/fail-fast-bash-scripting.html
set -euov pipefail
# Not supported in travis (xenial)
# shopt -s inherit_errexit

# local host machine's minikube VM IP
minikubeIP=$(minikube ip)

# Create the K8S environment
terraform apply -var="minikube-ip=${minikubeIP}" -input=false -auto-approve ./test
# Database username and password are from Travis environment variables..for simplicity.  Travis secretes or Helm templates may be better.
# kubectl create secret generic db-user-pass --from-literal=db_username=$DB_USER --from-literal=db_password=$DB_PASSWORD --namespace=eo-services

# wait for k8S and pods to start-up
sleep 60

# Make sure created pod is scheduled and running.
#- JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl -n default get pods -lapp=travis-example -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1;echo "waiting for travis-example deployment to be available"; kubectl get pods -n default; done

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
    #- kubectl expose deployment catalogue-service-deployment --name=cat-svce2 --port=8083 --target-port=7000 --type=NodePort
    #- kubectl get svc cat-svce
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

echo Running integration tests
# Environment variables used by the Java integration tests if set
export SEARCH_SERVICE_HOST=${minikubeIP}
export SEARCH_SERVICE_PORT=${revProxyNodePort}
# ./gradlew integrationTest

sleep 60

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

    #kubectl describe jobs/pi --namespace=eo-user-compute
    #kubectl describe job pi   --namespace=eo-user-compute

    kubectl describe quota --namespace=eo-user-compute
fi

kubectl describe job pi   --namespace=eo-user-compute

# Debug Persistent Volumes, PV Claims and Storage Classes
kubectl describe pv
kubectl describe pvc --namespace=eo-user-compute
kubectl get storageclass


kubectl logs --namespace=eo-user-compute job/pi --all-containers=true
