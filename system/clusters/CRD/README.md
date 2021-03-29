# Custom Resource Definitions

It seems that these need to be deployed before any components that try to use them - otherwise a validation error occurs for the dependent components.

## Sealed Secrets

https://raw.githubusercontent.com/bitnami-labs/sealed-secrets/main/helm/sealed-secrets/crds/sealedsecret-crd.yaml

## Cert Manager

https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.crds.yaml
