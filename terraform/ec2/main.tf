provider "aws" {
  region = local.aws_region
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# terraform {
#   backend "s3" {
#     bucket         = ""
#     dynamodb_table = ""
#     key            = ""
#     region         = ""
#   }
# }

locals {
  aws_region                    = "us-east-1"
  ec2_instance_type             = "t2.medium"
  distribution                  = "ubuntu" # Allow values:ubuntu or redhat or amazon-linux
  sg_name                       = "ubuntu-sg"
  instance_name                 = "ubuntu-vs"
  vpc_id                        = "vpc-068852590ea4b093b"
  subnet_id                     = "subnet-096d45c28d9fb4c14"
  root_volume_size              = 30 # this should be at least 30 for windows and 8 for linux
  instance_count                = 1
  enable_termination_protection = false
  ec2_instance_key_name         = "terraform-aws"
  allowed_ports = [
    22,
    3000,
    5000,
    8080,
    80,
  ]
  tags = {
    "id"             = "2560"
    "owner"          = "DevOps Easy Learning"
    "teams"          = "DEL"
    "environment"    = "dev"
    "project"        = "del"
    "create_by"      = "Terraform"
    "cloud_provider" = "aws"
  }
}

module "ec2" {
  source                        = "git::https://git@github.com/devopstia/terraform-course-del.git//aws-terraform/modules/ec2?ref=main"
  aws_region                    = local.aws_region
  distribution                  = local.distribution
  ec2_instance_type             = local.ec2_instance_type
  sg_name                       = local.sg_name
  instance_name                 = local.instance_name
  ec2_instance_key_name         = local.ec2_instance_key_name
  vpc_id                        = local.vpc_id
  subnet_id                     = local.subnet_id
  root_volume_size              = local.root_volume_size
  instance_count                = local.instance_count
  allowed_ports                 = local.allowed_ports
  enable_termination_protection = local.enable_termination_protection
  tags                          = local.tags
}
