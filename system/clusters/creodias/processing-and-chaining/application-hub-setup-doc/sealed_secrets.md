# Creating K8s Sealed Secrets for the Application Hub Helm Chart

In this section, we will walk you through the process of creating K8s sealed secrets for the Application Hub helm chart. Sealed secrets provide a secure way to store sensitive information, such as OAuth client credentials, in Kubernetes clusters. Let's get started:

### Step 1: Clone the EOEPCA Repos
- First, clone the **eoepca** repository, which contains the helm chart values for all EOEPCA platform components:
  ```
  git clone git@github.com:EOEPCA/eoepca.git
  ```

### Step 2: Modify the Script
- Navigate to the folder **system/clusters/creodias/processing-and-chaining** within the cloned repository.
- Open the script **application-hub-sealed-secrets-create.sh** and uncomment the following lines by removing the leading '#' symbol:
  ```
  JUPYTERHUB_CRYPT_KEY=$(openssl rand -hex 32)
  OAUTH_CLIENT_ID="${1:-set-client-id-here}"
  OAUTH_CLIENT_SECRET="${2:-set-client-secret-here}"
  ```

### Step 3: Set OAuth Client Properties
- Set the **OAUTH_CLIENT_ID** and **OAUTH_CLIENT_SECRET** properties with the values retrieved from the ["Open ID Creation"](gluu.md) section. Replace the placeholders "${1:-set-client-id-here}" and "${2:-set-client-secret-here}" with the actual values.

### Step 4: Execute the Script
- Run the script **application-hub-sealed-secrets-create.sh** to generate the sealed secret manifest file for the Application Hub using kubeseal:
  ```
  ./application-hub-sealed-secrets-create.sh
  ```

### Step 5: Deploy the Sealed Secret
- The above step will create a sealed secret manifest file named **application-hub-sealed-secrets.yaml**. To deploy the sealed secret, use the following command:
  ```
  kubectl create -f application-hub-sealed-secrets.yaml
  ```

Congratulations! You have successfully created and deployed K8s sealed secrets for the Application Hub helm chart.

Please proceed to the next step: [Helm Chart deployment](chart_deploy.md)