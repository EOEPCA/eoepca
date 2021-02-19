#!/bin/bash
PEP_ID=$(kubectl get pods | grep pep-engine | cut -d ' ' -f1 | tr '\n' ' ')
kubectl exec $PEP_ID -- management_tools remove --all
PDP_ID=$(kubectl get pods | grep pdp-engine | cut -d ' ' -f1 | tr '\n' ' ')
kubectl exec $PDP_ID -- management_tools remove --all
ps -ef | grep chrome | grep -v grep | awk '{print $2}' | xargs kill -9


