# Configure the OpenStack Provider

variable "password" {
  type = string
}

provider "openstack" {
  auth_url = var.auth_url
  user_name = var.user_name
  password = var.password
  tenant_id = var.tenant_id
  tenant_name = var.tenant_name
  user_domain_name = var.user_domain_name
  region = var.region
}

# Create a computing node with Ubuntu 16.04 LTS

module "creodias" {
  source = "./creodias"

}
/*
module "template-service" {
  source = "../global/template-svce"
  db_username = "one"
  db_password = "another"
} */
