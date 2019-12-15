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
