variable "image" {
default = "Ubuntu 16.04 LTS"
}

variable "flavor" {
default = "eo1.small"
}

variable "ssh_key_file" {
default = "~/.ssh/cloud.key"
}

variable "ssh_user_name" {
default = "eouser"
}

variable "external_network_name" {
default = "external2"
}

variable "pool" {
default = "external2"
}