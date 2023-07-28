# Deployment of Application Hub using Helm

In this section, we will guide you through the deployment of the Application Hub using Helm. If you are using Flux, you can skip this section, as Flux automatically deploys the Helm chart for you.

## Step 1: Clone the EOEPCA and Helm-charts-dev Repositories
To get started, follow these steps to clone the necessary repositories:

- Clone the **eoepca** repository, which contains the Helm chart values for all EOEPCA platform components:
  ```bash
  git clone git@github.com:EOEPCA/eoepca.git
  ```

- Clone the **helm-chart-dev** repository, which contains the Helm chart templates for all EOEPCA platform components:
  ```bash
  git clone git@github.com:EOEPCA/helm-charts.git
  ```

## Step 2: Deploy the Helm Chart
Now, let's deploy the Application Hub using Helm. Execute the following command:

```bash
helm upgrade --install application-hub helm-charts/tree/main/charts/application-hub -f system/clusters/creodias/processing-and-chaining/proc-application-hub.yaml -n proc
```

Congratulations! You have successfully deployed the Application Hub using Helm.
Please proceed to the next step: [Application Hub group creation](groups.md)