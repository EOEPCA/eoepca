# EOEPCA System Deployment

## Fleet

GitOps deployment management.

### Useful commands

#### install the Fleet CustomResourcesDefintions
```
helm -n fleet-system upgrade -i --create-namespace --wait \
    fleet-crd https://github.com/rancher/fleet/releases/download/v0.3.1/fleet-crd-0.3.1.tgz
```

#### install the Fleet controllers
```
helm -n fleet-system upgrade -i --create-namespace --wait \
    fleet https://github.com/rancher/fleet/releases/download/v0.3.1/fleet-0.3.1.tgz
```

#### uninstall
```
helm -n fleet-system uninstall fleet
helm -n fleet-system uninstall fleet-crd
```

#### Register GitRepo
```
helm install --set branch=`git branch --show-current` eoepca ./eoepca-repos
```

#### Check GitRepo status
```
helm status eoepca
```

#### Delete GitRepo resource
```
helm uninstall eoepca
```
