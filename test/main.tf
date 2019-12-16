provider "kubernetes" {
}

module "template-svce" {
  source = "./template-svce"
}
