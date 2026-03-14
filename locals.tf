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

  # Validation logic for subnets within VPC and non-overlapping subnets
  all_subnet_cidrs  = concat(var.public_subnet_cidrs, var.private_subnet_cidrs)
  vpc_prefix_length = tonumber(split("/", var.vpc_cidr)[1])

  public_subnets_within_vpc = alltrue([
    for cidr in var.public_subnet_cidrs :
    tonumber(split("/", cidr)[1]) >= local.vpc_prefix_length &&
    contains([
      for idx in range(pow(2, tonumber(split("/", cidr)[1]) - local.vpc_prefix_length)) :
      cidrsubnet(var.vpc_cidr, tonumber(split("/", cidr)[1]) - local.vpc_prefix_length, idx)
    ], cidr)
  ])

  private_subnets_within_vpc = alltrue([
    for cidr in var.private_subnet_cidrs :
    tonumber(split("/", cidr)[1]) >= local.vpc_prefix_length &&
    contains([
      for idx in range(pow(2, tonumber(split("/", cidr)[1]) - local.vpc_prefix_length)) :
      cidrsubnet(var.vpc_cidr, tonumber(split("/", cidr)[1]) - local.vpc_prefix_length, idx)
    ], cidr)
  ])

  overlapping_subnet_pairs = flatten([
    for left_idx, left_cidr in local.all_subnet_cidrs : [
      for right_idx, right_cidr in local.all_subnet_cidrs : "${left_cidr} overlaps ${right_cidr}"
      if right_idx > left_idx && (
        (
          tonumber(split("/", right_cidr)[1]) >= tonumber(split("/", left_cidr)[1]) &&
          contains([
            for idx in range(pow(2, tonumber(split("/", right_cidr)[1]) - tonumber(split("/", left_cidr)[1]))) :
            cidrsubnet(left_cidr, tonumber(split("/", right_cidr)[1]) - tonumber(split("/", left_cidr)[1]), idx)
          ], right_cidr)
          ) || (
          tonumber(split("/", left_cidr)[1]) > tonumber(split("/", right_cidr)[1]) &&
          contains([
            for idx in range(pow(2, tonumber(split("/", left_cidr)[1]) - tonumber(split("/", right_cidr)[1]))) :
            cidrsubnet(right_cidr, tonumber(split("/", left_cidr)[1]) - tonumber(split("/", right_cidr)[1]), idx)
          ], left_cidr)
        )
      )
    ]
  ])
}
