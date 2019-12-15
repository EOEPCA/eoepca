provider "kubernetes" {
  host = "https://192.168.99.100:8443"
}

module "template-svce" {
  source = "./template-svce"
}
