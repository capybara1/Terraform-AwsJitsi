variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "email" {
  type = string
}

variable "domain" {
  type = string
}

variable "ssh_whitelist" {
  type = set(string)
}

variable "public_key_path" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_root_volume_size" {
  type = number
}
