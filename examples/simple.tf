terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "secure_vpc" {
  source = "../"

  name_prefix          = "example-basic"
  environment          = "dev"
  vpc_cidr             = "10.10.0.0/16"
  azs                  = local.azs
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.101.0/24", "10.10.102.0/24"]
}

output "vpc_id" {
  description = "ID of the VPC created by the example."
  value       = module.secure_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs created by the example."
  value       = module.secure_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs created by the example."
  value       = module.secure_vpc.private_subnet_ids
}
