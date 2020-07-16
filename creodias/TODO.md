# TODO

* Output node IPs from terraform
* Add LoadBalancer to Terraform with correct Listener configs
* Node setup for each node
  * `ssh -J eouser@BASTION-IP eouser@NODE-IP 'bash -s - eouser' <PATH/rke-node-setup.sh`
* Setup `rke/cluster.yml` file with proper node IP values
* Run `rke up`
* Establish ssh tunnel to the Kube API Server via the bastion
  * `ssh -f eouser@BASTION-IP -L 6443:API-SERVER-IP:6443 -N`
  * The API-SERVER-IP is the one in the file `kube_config_cluster.yml` - probably the master node
* Investigate whether sshtunnel offers a better solution
  * https://sshuttle.readthedocs.io/en/stable/
* Update the kube config file `kube_config_cluster.yml` that is output by rke
* Invoke kubectl commands via `kubectl --kubeconfig=kube_config_cluster.yml`
* Attempt `deployEOEPCA`
