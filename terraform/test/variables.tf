variable "db_username" {
  type = string
  default = "an_user"
}

variable "db_password" {
  type = string
  default = "a_password"
}

variable "dh_user_email" {
  type = string
  default = "somebody@github.com"
}

variable "dh_user_name" {
  type = string
  default = "username"
}

variable "dh_user_password" {
  type = string
  default = "password"
}

variable "wspace_user_name" {
  type = string
  default = "username"
}

variable "wspace_user_password" {
  type = string
  default = "password"
}

variable "hostname" {
  type = string
}

variable "public_ip" {
  type = string
}

variable "nfs_server_address" {
  type = string
}

variable "storage_class" {
  type = string
  default = "eoepca-nfs"
}

variable "um-login-config_file" {
  type = string
  default = "um-login-config.json.tmpl"
}

variable "kube_config_path" {
  type = string
  default = "../../kubernetes/kube_config_cluster.yml"
}
