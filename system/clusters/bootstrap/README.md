# Cluster Bootstrap

It seems that Custom Resource Definitions need to be deployed before any components that try to use them - otherwise a validation error occurs for the dependent components. Thus we pre-deploy here any such components.

## Sealed Secrets

* Sealed Secrets github: https://github.com/bitnami-labs/sealed-secrets
* Installation: https://github.com/bitnami-labs/sealed-secrets#installation
* Flux reference: https://toolkit.fluxcd.io/guides/sealed-secrets/

## Cert Manager

* Cert Manager github: https://github.com/jetstack/cert-manager
* Installation: https://artifacthub.io/packages/helm/jetstack/cert-manager/1.2.0
