PEP_ID=$(kubectl get pods | grep pep-engine | cut -d ' ' -f1 | tr '\n' ' ')
kubectl delete pods ${PEP_ID}
PDP_ID=$(kubectl get pods | grep pdp-engine | cut -d ' ' -f1 | tr '\n' ' ')
kubectl delete pods ${PDP_ID}
ps -ef | grep chrome | grep -v grep | awk '{print $2}' | xargs kill -9


