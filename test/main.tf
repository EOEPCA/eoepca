provider "kubernetes" {
  host = "https://10.30.0.75:8443"
}

module "template-svce" {
  source = "./template-svce"
}
