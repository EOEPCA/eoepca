# TODO

* Add LoadBalancer to Terraform with correct Listener configs
* Add NFS server
* Output node IPs from terraform
* Establish a 'vpn' to the cluster using sshuttle...
  * https://sshuttle.readthedocs.io/en/stable/
  * Install...<br>`TBD`
  * Full VPN...<br>`sshuttle --dns -NHr eouser@185.52.192.70 192.168.123.0/24`
  * Simpler...<br>`sshuttle -r eouser@185.52.192.70 192.168.123.0/24`
* Node setup for each node
  * `ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null eouser@NODE-IP 'bash -s - eouser' < PATH/rke-node-setup.sh`
  * Add `-J eouser@BASTION-IP` if sshuttle is NOT being used
  * **Can do these in parallel if being clever**
* Setup `rke/cluster.yml` file with proper node IP values
* Run `rke up`
* (ONLY IF sshuttle is NOT used) Establish ssh tunnel to the Kube API Server via the bastion
  * `ssh -f eouser@BASTION-IP -L 6443:API-SERVER-IP:6443 -N`
  * The API-SERVER-IP is the one in the file `kube_config_cluster.yml` - probably the master node
  * Update the kube config file `kube_config_cluster.yml` that is output by rke
* Invoke kubectl commands via...<br>`kubectl --kubeconfig=kube_config_cluster.yml <args>`
  * Or copy the config...<br>`cp kube_config_cluster.yml ~/.kube/config`
* Attempt `deployEOEPCA`
