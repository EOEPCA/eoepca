# Install minikube and kubectl
K8S_VER=v1.13.0
TF_VER=0.12.25
MINIKUBE_VER=v1.9.1

# Make root mounted as rshared to fix kube-dns issues.
mount --make-rshared /

echo "##### Installing minikube version $MINIKUBE_VER and kubectl version $K8S_VER"
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/${K8S_VER}/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

curl -Lo minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_VER}/minikube-linux-amd64 
chmod +x minikube 
mv minikube /usr/local/bin/

echo "##### (Re)start Minikube cluster"
export CHANGE_MINIKUBE_NONE_USER=true
minikube delete --purge --all
minikube start --mount-string='/data:/data' --vm-driver=none --bootstrapper=kubeadm --kubernetes-version=${K8S_VER} --extra-config=apiserver.authorization-mode=RBAC

minikube addons enable ingress ## Substitute this for kubernetes deployment

# Fix the kubectl context, as it's often stale.
minikube update-context

# Wait for Kubernetes to be up and ready.
echo "##### Waiting for kubernetes cluster to be ready"
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done

kubectl cluster-info

sudo chmod o+r ${HOME}/.kube/config
sudo chmod -R o+r ${HOME}/.minikube/
sudo chown -R $USER $HOME/.kube $HOME/.minikube

echo "##### Installing Terraform version $TF_VER"
sudo apt-get install unzip
curl -sLo /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip
unzip /tmp/terraform.zip -d /tmp
chmod +x /tmp/terraform
mv /tmp/terraform /usr/local/bin/
export PATH="~/bin:$PATH"
