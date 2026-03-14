locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "network"
  }

  public_subnet_count  = min(length(var.azs), length(var.public_subnet_cidrs))
  private_subnet_count = min(length(var.azs), length(var.private_subnet_cidrs))

  public_subnets = {
    for idx in range(local.public_subnet_count) : var.azs[idx] => {
      az   = var.azs[idx]
      cidr = var.public_subnet_cidrs[idx]
    }
  }

  private_subnets = {
    for idx in range(local.private_subnet_count) : var.azs[idx] => {
      az   = var.azs[idx]
      cidr = var.private_subnet_cidrs[idx]
    }
  }
}
