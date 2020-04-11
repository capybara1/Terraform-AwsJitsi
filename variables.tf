variable "aws_profile" {
  description = "The AWS CLI profile."
  default     = "default"
}

variable "aws_region" {
  description = "The AWS region."
  default     = "eu-central-1"
}

variable "prefix" {
  description = "The common prefix for names."
  default     = "Jitsi"
}

variable "vpc_cidr_block" {
  description = "The VPC network."
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  description = "The number of public subnets."
  default     = 2
}

variable "private_subnet_count" {
  description = "The number of private subnets."
  default     = 2
}

variable "domain" {
  description = "The fully qualified name of the DNS domain."
}

variable "zone" {
  description = "The name of the DNS zone."
}

variable "key_name" {
  description = "The name of the RSA key pair in AWS."
  default     = "Jitsi-Keys"
}

variable "public_key_path" {
  description = "Path to the RSA public key."
}

variable "instance_type" {
  description = "AWS EC2 instance type."
  default     = "t3.large"
}

variable "images" {
  description = "AWS machine images for specific regions."
  type        = map
  default = {
    eu-central-1 = "ami-0b418580298265d5c" # Ubuntu 18.04 LTS (64-bit x86)
  }
}
