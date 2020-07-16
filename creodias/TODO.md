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
* Investigate whether sshuttle offers a better solution
  * https://sshuttle.readthedocs.io/en/stable/
  * Install...<br>``
  * Full VPN...<br>`sshuttle --dns -NHr eouser@185.52.192.70 192.168.123.0/24`
  * Simpler...<br>`sshuttle -r eouser@185.52.192.70 192.168.123.0/24`
* Update the kube config file `kube_config_cluster.yml` that is output by rke
  * NOT NEEDED if sshuttle is used
* Invoke kubectl commands via...<br>`kubectl --kubeconfig=kube_config_cluster.yml <args>`
  * Or copy the config...<br>`cp kube_config_cluster.yml ~/.kube/config`
* Attempt `deployEOEPCA`
