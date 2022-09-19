#!/usr/bin/env bash
NAMESPACE="um"
cd customizations/oxauth
tar -czvf ../../customizations_oxauth.tar.gz .
cd ../oxtrust
tar -czvf ../../customizations_oxtrust.tar.gz .
cd ../../
kubectl create configmap front-customizations -n $NAMESPACE --from-file=customizations_oxauth.tar.gz --from-file=customizations_oxtrust.tar.gz -o yaml --dry-run | kubectl replace -f -
rm -rf ./*.tar.gz
OXAUTH=$(kubectl get deployment -n $NAMESPACE | grep oxauth | awk '{print $1}')
OXTRUST=$(kubectl get statefulsets -n $NAMESPACE | grep oxtrust | awk '{print $1}')
kubectl scale deployment $OXAUTH --replicas 0 -n $NAMESPACE
kubectl scale statefulsets $OXTRUST --replicas 0 -n $NAMESPACE
sleep 5
kubectl scale deployment $OXAUTH --replicas 1 -n $NAMESPACE
kubectl scale statefulsets $OXTRUST --replicas 1 -n $NAMESPACE
