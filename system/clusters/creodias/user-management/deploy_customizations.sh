#!/usr/bin/env bash
cd customizations/oxauth
tar -czvf ../../customizations_oxauth.tar.gz .
cd ../oxtrust
tar -czvf ../../customizations_oxtrust.tar.gz .
cd ../../
kubectl create configmap front-customizations --from-file=customizations_oxauth.tar.gz --from-file=customizations_oxtrust.tar.gz -o yaml --dry-run | kubectl replace -f -
OXAUTH=$(kubectl get deployment | grep oxauth | awk '{print $1}')
OXTRUST=$(kubectl get statefulsets | grep oxtrust | awk '{print $1}')
kubectl scale deployment $OXAUTH --replicas 0
kubectl scale statefulsets $OXTRUST --replicas 0
sleep 5
kubectl scale deployment $OXAUTH --replicas 1
kubectl scale statefulsets $OXTRUST --replicas 1