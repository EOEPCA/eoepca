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

## operations tooling

common tooling to support resp. automate operations tasks is deployed in the `infra` namespace 

### automated certificate management 

implemented using Cert-Manager with LetsEncrypt configuration

also see section certificates above

### centralized logging

implemented using the EFK stack made of Elasticsearch, Fluentd, and Kibana, all released under the Apache license

Elasticsearch is a search and analytics engine, Fluentd an open source data collector for unified logging and Kibana lets users visualize data with charts and graphs from Elasticsearch

log output from all containers running in the cluster are centrally available and searchable [here](https://kibana.mundi.eoepca.org) (requires authorization - see access managment below)

### metrics monitoring

implemented using Prometheus, an open-source monitoring system and time series database, and Grafana, an open source metric analytics & visualization suite

Prometheus is used as the central component of metrics monitoring as it features a multi-dimensional data model to store and manage metrics and KPIs based on data collected from the various services

data collection can be easily enabled for all containers via an k8s annotation configration, e.g. 

```
  annotations:
        prometheus.io/scrape: "true"
        prometheus.io/path: "/metrics"
        prometheus.io/port: "80"
```

as simple UI for metrics is directly provided via Prometheus and accessible [here](https://prometheus.mundi.eoepca.org) (requires authorization - see access managment below)

a more sophisticated UI for interactive monitoring of continuous status and performance metrics is established through Grafana accessible [here](https://grafana.mundi.eoepca.org) (requires authorization - see access managment below), visualizing the gathered time series data for infrastructure and application analytics

### access management 

access to public endpoints of the cluster can be protected via ingress annotations, e.g.

```
        nginx.ingress.kubernetes.io/auth-response-headers: X-Auth-Request-User, X-Auth-Request-Email
        nginx.ingress.kubernetes.io/auth-signin: https://test.mundi.eoepca.org/oauth2/start?rd=%2F$server_name$escaped_request_uri
        nginx.ingress.kubernetes.io/auth-url: https://test.mundi.eoepca.org/oauth2/auth
```

using the open source OAuth-Proxy tool connected to an OIDC provider

the OIDC provider (currently an AWS Cognito user pool managed by EOX) is connected via `oidc-issuer-url: https://cognito-idp.eu-central-1.amazonaws.com/eu-central-1_7mjYRQYll` and corresponding oauth `client_id` and `client_secret` config

### push-based GitOps pipeline

Using webhook receivers it is possible to react to extnerla events like a "push" event to the github repository. A corresponding github [webhook](https://github.com/EOEPCA/eoepca/settings/hooks/279780311) was created and configured accordingly.
