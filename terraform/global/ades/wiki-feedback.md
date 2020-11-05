# ADES Wiki Feedback

## Minikube Setup Guide

For consistency with the provided commands `kubectl create serviceaccount ades` should include the 'eoepca' namespace...

```
kubectl -n eoepca create serviceaccount ades
```

Chronology problem -> the 'eoepca' namespace is created in the page 'Deploy and Configure the ADES' - which comes after this one.

## Deploy and Configure the ADES

The sample file 'config/ades-config.env.sample' is not consistent with the sample included within this page, e.g. parameter `LOCAL_ADES_CONFIG_PATH=/home/test/proc-ades/config` is not listed -> Is it required?
