# Helm chart for resource-catalogue service

Debug with:

```bash
helm install --dry-run --debug resource-catalogue .
```

Deploy with:

```bash
helm install resource-catalogue .
```

The server should then be made available at the host/port specified by
`minikube service pycsw --url`.
