variable "aws_profile" {
  description = "The AWS CLI profile."
  default     = "default"
}

variable "aws_region" {
  description = "The AWS region."
  default     = "eu-central-1"
}

variable "vpc_cidr_block" {
  description = "The VPC network."
  default ="10.0.0.0/16"
}

variable "domain" {
  description = "The DNS domain."
}

variable "zone" {
  description = "The DNS domain."
  default     = "${var.domain}."
}

variable "key_name" {
  description = "The name of the RSA key pair in AWS."
  default     = "sonarqube-keys"
}

variable "public_key_path" {
  description = "Path to the RSA public key."
}
