# Configure the Kubernetes provider

provider "kubernetes" {
  load_config_file = "false"

  host = "45.130.29.109:16443"

  client_certificate     = file("~/.minikube/certs/cert.pem")
  client_key             = file("~/.minikube/certs/key.pem")
  cluster_ca_certificate = file("~/.minikube/certs/ca.pem")
}

module "template-service" {
  source = "../global/template-svce"
  db_username = "one"
  db_password = "another"
}