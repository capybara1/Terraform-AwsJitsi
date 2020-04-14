variable "prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = set(string)
}

variable "instance_id" {
  type = string
}

variable "service_domain" {
  type = string
}

variable "cert_domain" {
  type = string
}

variable "zone" {
  type = string
}
