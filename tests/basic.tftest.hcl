mock_provider "aws" {}

variables {
  name_prefix          = "test-secure-vpc"
  environment          = "test"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
}

run "plan_succeeds_with_valid_inputs" {
  command = plan

  assert {
    condition     = length(output.public_subnet_ids) == 2
    error_message = "Expected exactly two public subnets in the plan."
  }

  assert {
    condition     = length(output.private_subnet_ids) == 2
    error_message = "Expected exactly two private subnets in the plan."
  }

  assert {
    condition     = length(keys(output.nat_gateway_ids)) == 2
    error_message = "Expected one NAT Gateway per Availability Zone."
  }
}

run "fails_when_public_subnets_are_less_than_two" {
  command = plan

  variables {
    public_subnet_cidrs = ["10.0.1.0/24"]
  }

  expect_failures = [var.public_subnet_cidrs]
}

run "fails_when_private_subnets_are_less_than_two" {
  command = plan

  variables {
    private_subnet_cidrs = ["10.0.101.0/24"]
  }

  expect_failures = [var.private_subnet_cidrs]
}

run "fails_when_azs_are_duplicated" {
  command = plan

  variables {
    azs = ["us-east-1a", "us-east-1a"]
  }

  expect_failures = [var.azs]
}

run "fails_when_azs_and_private_subnets_have_different_lengths" {
  command = plan

  variables {
    private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  }

  expect_failures = [aws_vpc.main]
}
