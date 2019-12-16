variable "minikube-ip" {
  type = string
  default = "https://10.30.0.75:8443"
}

provider "kubernetes" {
}

module "template-svce" {
  source = "./template-svce"
}
