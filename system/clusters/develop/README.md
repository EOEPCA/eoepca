# deployment

the declaritive configuration in this git repository is sourcing the application components (EOEPCA building blocks) of the k8s development cluster running on CreoDias/CloudFerro

## repositories for Helm charts

### namespace "common"

kind: HelmRepository
- `stable` https://charts.helm.sh/stable/
- `bitnami` https://charts.bitnami.com/bitnami/
- `jetstack` https://charts.jetstack.io

## certificates

certificates are automatically generated via lets-encrypt

add annotation `cert-manager.io/cluster-issuer: letsencrypt` and proper `tls` section to ingress definition

## secret handling

never commit a k8s secret to git - use a sealed-secret!

1) install [kubeseal](https://github.com/bitnami-labs/sealed-secrets/releases) and download `pub-sealed-secrets.pem` from EOEPCA github repository
2) create k8s Secret `secret.yaml`locally
3) `kubeseal --format=yaml --cert=pub-sealed-secrets.pem < secret.yaml > sealed-secret.yaml`
4) commit `sealed-secret.yaml` to git

note: the sealed-secret will be decrypted in cluster automatically and made available as regular k8s secret