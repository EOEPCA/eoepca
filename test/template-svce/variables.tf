variable "region" {
  default = "eu-west-1"
}

variable "amis" {
  type = map(string)
  default = {
    "us-east-1" = "ami-b374d5a5"
    "eu-west-1" = "ami-60349919"
  }
}

variable "db_username" {
  type = string
  default = "a_module_user"
}

variable "db_password" {
  type = string
  default = "a_module_user's_password"
}
