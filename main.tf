provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}


locals {
  server_subnet_index = 0
}


module "vpc" {
  source = "github.com/capybara1/Terraform-AwsBasicVpc?ref=v2.1.1"

  vpc_cidr_block            = var.vpc_cidr_block
  prefix                    = var.prefix
  number_of_private_subnets = 0
}

module "ec2" {
  source = "./modules/ec2"

  prefix                    = var.prefix
  vpc_id                    = module.vpc.vpc_id
  subnet_id                 = module.vpc.public_subnets[local.server_subnet_index].id
  email                     = var.email
  domain                    = var.domain
  ssh_whitelist             = var.ssh_whitelist
  public_key_path           = var.public_key_path
  instance_type             = var.instance_type
  instance_root_volume_size = var.instance_root_volume_size
}

module "lb" {
  source = "./modules/lb"

  prefix      = var.prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnets[*].id
  instance_id = module.ec2.instance_id
  domain      = var.domain
  zone        = var.zone
}
